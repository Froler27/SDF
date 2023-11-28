#iChannel0 "file://sdf.png"

const int MAX_MARCHING_STEPS = 255;
const float MIN_DIST = 0.0;
const float MAX_DIST = 100.0;
const float PRECISION = 0.001;

vec2 frag_coord;
vec2 screen_size;
float aspect;

float sdSphere(vec3 p, float r )
{
  vec3 offset = vec3(0, 0, -2);
  return length(p - offset) - r;
}

vec2 uvSphere(vec3 p)
{
  vec2 uv;
  vec3 n = normalize(p);
  float theta = acos(n.z);
  float totient = atan(n.y, n.x);
  if (totient <0.) {
    totient += radians(360.);
  }

  const float _1_PI = degrees(1./180.);

  uv.x = totient*_1_PI*0.5;
  uv.y = 1.-theta*_1_PI;

  return uv;
}

float rayMarch(vec3 ro, vec3 rd, float start, float end) {
  float depth = start;

  for (int i = 0; i < MAX_MARCHING_STEPS; i++) {
    vec3 p = ro + depth * rd;
    float d = sdSphere(p, 1.);
    depth += d;
    if (d < PRECISION || depth > end) break;
  }

  return depth;
}

vec3 calcNormal(vec3 p) {
    vec2 e = vec2(1.0, -1.0) * 0.0005; // epsilon
    float r = 1.; // radius of sphere
    return normalize(
      e.xyy * sdSphere(p + e.xyy, r) +
      e.yyx * sdSphere(p + e.yyx, r) +
      e.yxy * sdSphere(p + e.yxy, r) +
      e.xxx * sdSphere(p + e.xxx, r));
}

struct Camera
{
  vec3 pos;
  float fov;
  float aspect;
  vec3 rd;
} main_camera;

void init_main_camera()
{
  main_camera.fov = 60.;
  main_camera.aspect = iResolution.x/iResolution.y;
  main_camera.pos = vec3(0, 0, 3);

  float z_near = 0.5*tan(radians(90.-main_camera.fov*0.5));
  vec2 uv = (frag_coord - .5*screen_size)/screen_size.y;
  main_camera.rd = normalize(vec3(uv, -z_near));
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
  frag_coord = fragCoord;
  screen_size = iResolution.xy;
  aspect = screen_size.x/screen_size.y;
  init_main_camera();
  vec3 backgroundColor = vec3(0.835, 1, 1);

  vec3 col = vec3(0);
  vec3 ro = main_camera.pos; // ray origin that represents camera position
  vec3 rd = main_camera.rd; // ray direction

  float d = rayMarch(ro, rd, MIN_DIST, MAX_DIST); // distance to sphere

  if (d > MAX_DIST) {
    col = backgroundColor; // ray didn't hit anything
  } else {
    vec3 p = ro + rd * d; // point on sphere we discovered from ray marching
    vec3 normal = calcNormal(p);
    vec3 lightPosition = vec3(2, 2, 7);
    vec3 lightDirection = normalize(lightPosition - p);

    // Calculate diffuse reflection by taking the dot product of 
    // the normal and the light direction.
    float dif = clamp(dot(normal, lightDirection), 0., 1.);

    vec2 uv = uvSphere(p);
    vec3 obj_col = texture(iChannel0, uv).xyz;
    //vec3 obj_col = vec3(1, 0.58, 0.29);

    // Multiply the diffuse reflection value by an orange color and add a bit
    // of the background color to the sphere to blend it more with the background.
    col = dif * obj_col + backgroundColor * .2;
  }

  // Output to screen
  fragColor = vec4(col, 1.0);
}
