import asyncio
from dataclasses import dataclass
from pyodide import create_proxy
from pyodide.ffi import to_py
from js import (
    document,
    performance,
    console,
    WebGL2RenderingContext,
    Float32Array,
    requestAnimationFrame,
    fetch,
    createImageBitmap,
)


@dataclass
class PointerState:
    """Stores the current pointer position and click state."""

    x: float = 0.0
    y: float = 0.0
    down: bool = False
    up: bool = False


pointer_state = PointerState()

quad_renderer: "QuadRenderer | None" = None


def handle_pointer_down(x: float, y: float) -> None:
    """Process a pointer-down event at canvas coordinates ``(x, y)``."""

    pointer_state.x = x
    pointer_state.y = y
    pointer_state.down = True
    pointer_state.up = False

    canvas = document.getElementById("game")
    if not canvas or quad_renderer is None:
        return

    # Convert pixel coordinates to WebGL NDC (-1..1) space
    ndc_x = (x / canvas.width) * 2.0 - 1.0
    ndc_y = -((y / canvas.height) * 2.0 - 1.0)
    quad_renderer.hit_test(ndc_x, ndc_y)


def init_webgl() -> WebGL2RenderingContext:
    canvas = document.getElementById("game")
    if not canvas:
        raise RuntimeError("<canvas id='game'> not found")
    gl = canvas.getContext("webgl2")
    if not gl:
        raise RuntimeError("WebGL2 not supported")
    # Set clear color to teal (dark blue-green)
    gl.clearColor(0.0, 0.25, 0.3, 1.0)
    gl.viewport(0, 0, canvas.width, canvas.height)
    gl.clear(gl.COLOR_BUFFER_BIT)

    def _on_pointer_down(evt) -> None:
        e = to_py(evt)
        handle_pointer_down(float(e.offsetX), float(e.offsetY))

    def _on_pointer_up(evt) -> None:
        e = to_py(evt)
        pointer_state.down = False
        pointer_state.up = True

    canvas.addEventListener("pointerdown", create_proxy(_on_pointer_down))
    canvas.addEventListener("pointerup", create_proxy(_on_pointer_up))
    return gl


async def load_image_bitmap(url: str):
    resp = await fetch(url)
    blob = await resp.blob()
    bitmap = await createImageBitmap(blob)
    return bitmap


class QuadRenderer:
    """Utility for drawing colored rectangles using WebGL2."""

    def __init__(self, gl: WebGL2RenderingContext) -> None:
        self.gl = gl
        self.quads: list[tuple[str, float, float, float, float]] = []
        vs_source = """
            #version 300 es
            in vec2 a_pos;
            uniform vec2 u_pos;
            uniform vec2 u_size;
            void main() {
                vec2 pos = a_pos * u_size + u_pos;
                gl_Position = vec4(pos, 0.0, 1.0);
            }
        """

        fs_source = """
            #version 300 es
            precision mediump float;
            uniform vec4 u_color;
            out vec4 outColor;
            void main() {
                outColor = u_color;
            }
        """

        self.program = self._create_program(vs_source, fs_source)
        self.u_pos = gl.getUniformLocation(self.program, "u_pos")
        self.u_size = gl.getUniformLocation(self.program, "u_size")
        self.u_color = gl.getUniformLocation(self.program, "u_color")

        self.vao = gl.createVertexArray()
        gl.bindVertexArray(self.vao)
        self.vbo = gl.createBuffer()
        gl.bindBuffer(gl.ARRAY_BUFFER, self.vbo)
        vertices = Float32Array.new(
            [
                -0.5,
                -0.5,
                0.5,
                -0.5,
                -0.5,
                0.5,
                0.5,
                0.5,
            ]
        )
        gl.bufferData(gl.ARRAY_BUFFER, vertices, gl.STATIC_DRAW)
        attrib = gl.getAttribLocation(self.program, "a_pos")
        gl.enableVertexAttribArray(attrib)
        gl.vertexAttribPointer(attrib, 2, gl.FLOAT, False, 0, 0)
        gl.bindVertexArray(None)

    def _compile_shader(self, src: str, shader_type: int):
        gl = self.gl
        shader = gl.createShader(shader_type)
        gl.shaderSource(shader, src)
        gl.compileShader(shader)
        if not gl.getShaderParameter(shader, gl.COMPILE_STATUS):
            info = gl.getShaderInfoLog(shader)
            console.error(info)
            raise RuntimeError(info)
        return shader

    def _create_program(self, vs_src: str, fs_src: str):
        gl = self.gl
        vs = self._compile_shader(vs_src, gl.VERTEX_SHADER)
        fs = self._compile_shader(fs_src, gl.FRAGMENT_SHADER)
        program = gl.createProgram()
        gl.attachShader(program, vs)
        gl.attachShader(program, fs)
        gl.linkProgram(program)
        if not gl.getProgramParameter(program, gl.LINK_STATUS):
            info = gl.getProgramInfoLog(program)
            console.error(info)
            raise RuntimeError(info)
        gl.deleteShader(vs)
        gl.deleteShader(fs)
        return program

    def draw_quad(
        self,
        quad_id: str,
        x: float,
        y: float,
        w: float,
        h: float,
        r: float,
        g: float,
        b: float,
        a: float,
    ) -> None:
        gl = self.gl
        gl.useProgram(self.program)
        gl.bindVertexArray(self.vao)
        gl.uniform2f(self.u_pos, x, y)
        gl.uniform2f(self.u_size, w, h)
        gl.uniform4f(self.u_color, r, g, b, a)
        gl.drawArrays(gl.TRIANGLE_STRIP, 0, 4)
        gl.bindVertexArray(None)
        gl.useProgram(None)
        self.quads.append((quad_id, x, y, w, h))

    def clear_quads(self) -> None:
        self.quads.clear()

    def hit_test(self, x: float, y: float) -> None:
        """Check if point ``(x, y)`` in NDC space hits any stored quad."""

        for qid, qx, qy, qw, qh in self.quads:
            if (
                qx - qw / 2.0 <= x <= qx + qw / 2.0
                and qy - qh / 2.0 <= y <= qy + qh / 2.0
            ):
                console.log(f"Clicked quad: ID={qid}")
                return


class SpriteRenderer:
    """Renderer for textured quads using a sprite atlas."""

    def __init__(self, gl: WebGL2RenderingContext, texture) -> None:
        self.gl = gl
        self.texture = texture
        vs_source = """
            #version 300 es
            in vec2 a_pos;
            in vec2 a_uv;
            uniform vec2 u_pos;
            uniform vec2 u_size;
            uniform vec4 u_uv;
            out vec2 v_uv;
            void main() {
                vec2 pos = a_pos * u_size + u_pos;
                gl_Position = vec4(pos, 0.0, 1.0);
                v_uv = mix(u_uv.xy, u_uv.zw, a_uv);
            }
        """

        fs_source = """
            #version 300 es
            precision mediump float;
            uniform sampler2D u_tex;
            in vec2 v_uv;
            out vec4 outColor;
            void main() {
                outColor = texture(u_tex, v_uv);
            }
        """

        self.program = self._create_program(vs_source, fs_source)
        self.u_pos = gl.getUniformLocation(self.program, "u_pos")
        self.u_size = gl.getUniformLocation(self.program, "u_size")
        self.u_uv = gl.getUniformLocation(self.program, "u_uv")
        self.u_tex = gl.getUniformLocation(self.program, "u_tex")

        self.vao = gl.createVertexArray()
        gl.bindVertexArray(self.vao)
        self.vbo = gl.createBuffer()
        gl.bindBuffer(gl.ARRAY_BUFFER, self.vbo)
        vertices = Float32Array.new(
            [
                -0.5,
                -0.5,
                0.0,
                0.0,
                0.5,
                -0.5,
                1.0,
                0.0,
                -0.5,
                0.5,
                0.0,
                1.0,
                0.5,
                0.5,
                1.0,
                1.0,
            ]
        )
        gl.bufferData(gl.ARRAY_BUFFER, vertices, gl.STATIC_DRAW)
        stride = 4 * 4
        pos_attrib = gl.getAttribLocation(self.program, "a_pos")
        uv_attrib = gl.getAttribLocation(self.program, "a_uv")
        gl.enableVertexAttribArray(pos_attrib)
        gl.vertexAttribPointer(pos_attrib, 2, gl.FLOAT, False, stride, 0)
        gl.enableVertexAttribArray(uv_attrib)
        gl.vertexAttribPointer(uv_attrib, 2, gl.FLOAT, False, stride, 8)
        gl.bindVertexArray(None)

    @classmethod
    async def create(
        cls, gl: WebGL2RenderingContext, url: str
    ) -> "SpriteRenderer":
        bitmap = await load_image_bitmap(url)
        texture = gl.createTexture()
        gl.bindTexture(gl.TEXTURE_2D, texture)
        gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.NEAREST)
        gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.NEAREST)
        gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE)
        gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE)
        gl.texImage2D(
            gl.TEXTURE_2D,
            0,
            gl.RGBA,
            gl.RGBA,
            gl.UNSIGNED_BYTE,
            bitmap,
        )
        gl.bindTexture(gl.TEXTURE_2D, None)
        return cls(gl, texture)

    def _compile_shader(self, src: str, shader_type: int):
        gl = self.gl
        shader = gl.createShader(shader_type)
        gl.shaderSource(shader, src)
        gl.compileShader(shader)
        if not gl.getShaderParameter(shader, gl.COMPILE_STATUS):
            info = gl.getShaderInfoLog(shader)
            console.error(info)
            raise RuntimeError(info)
        return shader

    def _create_program(self, vs_src: str, fs_src: str):
        gl = self.gl
        vs = self._compile_shader(vs_src, gl.VERTEX_SHADER)
        fs = self._compile_shader(fs_src, gl.FRAGMENT_SHADER)
        program = gl.createProgram()
        gl.attachShader(program, vs)
        gl.attachShader(program, fs)
        gl.linkProgram(program)
        if not gl.getProgramParameter(program, gl.LINK_STATUS):
            info = gl.getProgramInfoLog(program)
            console.error(info)
            raise RuntimeError(info)
        gl.deleteShader(vs)
        gl.deleteShader(fs)
        return program

    def draw_sprite(
        self,
        x: float,
        y: float,
        w: float,
        h: float,
        u0: float,
        v0: float,
        u1: float,
        v1: float,
    ) -> None:
        gl = self.gl
        gl.useProgram(self.program)
        gl.bindVertexArray(self.vao)
        gl.activeTexture(gl.TEXTURE0)
        gl.bindTexture(gl.TEXTURE_2D, self.texture)
        gl.uniform1i(self.u_tex, 0)
        gl.uniform2f(self.u_pos, x, y)
        gl.uniform2f(self.u_size, w, h)
        gl.uniform4f(self.u_uv, u0, v0, u1, v1)
        gl.drawArrays(gl.TRIANGLE_STRIP, 0, 4)
        gl.bindVertexArray(None)
        gl.bindTexture(gl.TEXTURE_2D, None)
        gl.useProgram(None)


def start_main_loop(
    gl: WebGL2RenderingContext, sprites: SpriteRenderer
) -> None:
    global quad_renderer
    renderer = QuadRenderer(gl)
    quad_renderer = renderer
    last_fps_time = performance.now()
    frame_count = 0

    def _step(timestamp: float) -> None:
        nonlocal last_fps_time, frame_count
        gl.clear(gl.COLOR_BUFFER_BIT)
        renderer.clear_quads()
        renderer.draw_quad("red", -0.75, -0.75, 0.4, 0.4, 1.0, 0.0, 0.0, 1.0)
        renderer.draw_quad("green", 0.2, 0.2, 0.5, 0.3, 0.0, 1.0, 0.0, 1.0)
        sprites.draw_sprite(-0.5, -0.5, 0.4, 0.4, 0.0, 0.0, 0.25, 0.25)
        sprites.draw_sprite(0.3, 0.3, 0.4, 0.4, 0.25, 0.0, 0.5, 0.25)
        frame_count += 1
        if timestamp - last_fps_time >= 1000:
            fps = frame_count * 1000.0 / (timestamp - last_fps_time)
            console.log(f"FPS: {fps:.2f}")
            frame_count = 0
            last_fps_time = timestamp
        requestAnimationFrame(cb)

    cb = create_proxy(_step)
    requestAnimationFrame(cb)


async def main_loop() -> None:
    gl = init_webgl()
    sprites = await SpriteRenderer.create(gl, "/static/atlas.png")
    start_main_loop(gl, sprites)
    await asyncio.Future()  # Run forever


asyncio.ensure_future(main_loop())
