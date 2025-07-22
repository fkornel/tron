import asyncio
from pyodide import create_proxy
from js import (
    document,
    performance,
    console,
    WebGL2RenderingContext,
    Float32Array,
    requestAnimationFrame,
)


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
    return gl


class QuadRenderer:
    """Utility for drawing colored rectangles using WebGL2."""

    def __init__(self, gl: WebGL2RenderingContext) -> None:
        self.gl = gl
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
        vertices = Float32Array.new([
            -0.5,
            -0.5,
            0.5,
            -0.5,
            -0.5,
            0.5,
            0.5,
            0.5,
        ])
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
        self, x: float, y: float, w: float, h: float, r: float, g: float, b: float, a: float
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


def start_main_loop(gl: WebGL2RenderingContext) -> None:
    renderer = QuadRenderer(gl)
    last_fps_time = performance.now()
    frame_count = 0

    def _step(timestamp: float) -> None:
        nonlocal last_fps_time, frame_count
        gl.clear(gl.COLOR_BUFFER_BIT)
        renderer.draw_quad(-0.75, -0.75, 0.4, 0.4, 1.0, 0.0, 0.0, 1.0)
        renderer.draw_quad(0.2, 0.2, 0.5, 0.3, 0.0, 1.0, 0.0, 1.0)
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
    start_main_loop(gl)
    await asyncio.Future()  # Run forever


asyncio.ensure_future(main_loop())
