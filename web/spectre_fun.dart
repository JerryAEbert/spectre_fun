import 'dart:html';
import 'dart:math' as Math;
import 'package:spectre/spectre.dart';
import 'package:vector_math/vector_math_browser.dart';
import 'package:game_loop/game_loop.dart';

Math.Random rand = new Math.Random();

final String _canvasId = '#backbuffer';

GraphicsDevice _graphicsDevice;
GraphicsContext _graphicsContext;
ResourceManager _resourceManager;
DebugDrawManager _debugDrawManager;

GameLoop _gameLoop;

Viewport _viewport;
Camera _camera;
double _lastTime;

void gameFrame(GameLoop gameLoop) {
  double dt = gameLoop.dt;
  // Update the debug draw manager state
  _debugDrawManager.update(dt);
}

void renderFrame(GameLoop gameLoop) {

  // Clear the color buffer
  _graphicsContext.clearColorBuffer(0.0, 0.0, 0.0, 1.0);
  // Clear the depth buffer
  _graphicsContext.clearDepthBuffer(1.0);
  // Reset the context
  _graphicsContext.reset();
  // Set the viewport
  _graphicsContext.setViewport(_viewport);

  int numLines=400;
  double lx,ly;
  for(int i=0; i <= numLines; i++){
    lx = (2*rand.nextDouble()) - 1;
    ly = (2*rand.nextDouble()) - 1;
    _debugDrawManager.addLine(
        new vec3.raw(lx, ly, 0.0),
        new vec3.raw(4*lx, 4*ly, 0.0),
        new vec4.raw(1, 1, 1, 1.0));
  }


  // Prepare the debug draw manager for rendering
  _debugDrawManager.prepareForRender();
  // Render it
  _debugDrawManager.render(_camera);
}

// Handle resizes
void resizeFrame(GameLoop gameLoop) {

  CanvasElement canvas = gameLoop.element;
  // Set the canvas width and height to match the dom elements
  canvas.width = canvas.clientWidth;
  canvas.height = canvas.clientHeight;
  // Adjust the viewport dimensions
  _viewport.width = canvas.width;
  _viewport.height = canvas.height;
  // Fix the camera's aspect ratio
  _camera.aspectRatio = canvas.width.toDouble()/canvas.height.toDouble();
}


void main() {
  final String baseUrl = "${window.location.href.substring(0, window.location.href.length - "engine.html".length)}web/resources";
  CanvasElement canvas = query(_canvasId);
  assert(canvas != null);
  WebGLRenderingContext gl = canvas.getContext('experimental-webgl');

  assert(gl != null);

  // Create a GraphicsDevice
  _graphicsDevice = new GraphicsDevice(gl);
  // Print out GraphicsDeviceCapabilities
  print(_graphicsDevice.capabilities);
  // Get a reference to the GraphicsContext
  _graphicsContext = _graphicsDevice.context;
  // Create a resource manager and set it's base URL
  _resourceManager = new ResourceManager();
  _resourceManager.setBaseURL(baseUrl);
  // Create a debug draw manager and initialize it
  _debugDrawManager = new DebugDrawManager(_graphicsDevice);

  // Set the canvas width and height to match the dom elements
  canvas.width = canvas.clientWidth;
  canvas.height = canvas.clientHeight;

  // Create the viewport
  _viewport = _graphicsDevice.createViewport('view');
  _viewport.x = 0;
  _viewport.y = 0;
  _viewport.width = canvas.width;
  _viewport.height = canvas.height;

  // Create the camera
  _camera = new Camera();
  _camera.aspectRatio = canvas.width.toDouble()/canvas.height.toDouble();
  _camera.position = new vec3.raw(0.0, 0.0, -2.5);
  _camera.focusPosition = new vec3.raw(0.0, 0.0, 0.0);

  // Wireup game loop
  _gameLoop = new GameLoop(canvas);
  _gameLoop.onUpdate = gameFrame;
  _gameLoop.onRender = renderFrame;
  _gameLoop.onResize = resizeFrame;
  _gameLoop.start();
}