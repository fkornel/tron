import asyncio
from pyodide import create_proxy
from js import document, performance, console, WebGL2RenderingContext, requestAnimationFrame


def init_webgl() -> WebGL2RenderingContext:
    canvas = document.getElementById("game")
    if not canvas:
        raise RuntimeError("<canvas id='game'> not found")
    gl = canvas.getContext("webgl2")
    if not gl:
        raise RuntimeError("WebGL2 not supported")
    # Set clear color to teal (dark blue-green)
    gl.clearColor(0.0, 0.25, 0.3, 1.0)
    gl.clear(gl.COLOR_BUFFER_BIT)
    return gl


def start_main_loop(gl: WebGL2RenderingContext) -> None:
    last_fps_time = performance.now()
    frame_count = 0

    def _step(timestamp: float) -> None:
        nonlocal last_fps_time, frame_count
        gl.clear(gl.COLOR_BUFFER_BIT)
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
