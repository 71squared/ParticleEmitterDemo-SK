
void main()
{
    vec4 color;
    if (u_opacityModifyRGB == 1.0) {
        color = vec4(v_color_mix.r * v_color_mix.a,
                     v_color_mix.g * v_color_mix.a,
                     v_color_mix.b * v_color_mix.a,
                     v_color_mix.a);
		
    } else {
        color = v_color_mix;
    }

    gl_FragColor =  color * texture2D(u_texture, v_tex_coord);
}
