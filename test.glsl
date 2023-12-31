void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // Normalized pixel coordinates (from 0 to 1)
    vec2 uv = fragCoord/iResolution.xy;

    // Time varying pixel color
    vec3 col = 0.5 + 0.5*cos(iTime+uv.xyx+vec3(0,2,4));
    
    

    fragColor = vec4(1);
    
    if(fragCoord.x>iResolution.x/2.)
        if (fragCoord.y>iResolution.y/2.)
            fragColor = vec4(col,1.0);
}