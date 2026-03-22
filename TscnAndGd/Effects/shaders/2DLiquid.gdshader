// 2D liquid inside 'sphere' shader.
//Tags Progress Bar Use fV as a progress percent from 0 to 1

// Original Author: Mirza Beig
// Godot Implementation: RuverQ

// https://twitter.com/TheMirzaBeig
// https://www.youtube.com/@MirzaBeig

// https://twitter.com/RuverQuack

// Feel free troveto use this however you want.
// Modify, learn from it, copy-paste, etc...

// Original Shadertoy: https://www.shadertoy.com/view/Ds3BRN

shader_type canvas_item;

// fV = fill value
uniform float fV;
uniform float PI = 3.14;
void fragment() {
    vec2 uv = ((UV / -0.10)) + vec2(1.25,1.25);

    float
		sdf=length(uv),c=step(sdf,.85),
		
        vB=smoothstep(.1,.9,sin(uv.x+(PI*.5))-.3),
		vBA=vB*sin(TIME*4.)*.1,
        
        fW=(sin(((TIME*2.)+uv.x)*2.)*.05)+vBA,
		bW=(sin(((TIME*-2.)+uv.x)*2.+PI)*.05)-vBA,
		
        fA=(sin(TIME*4.)*.05)*vB,
        
        fP=fV * 2.3 +(sin((TIME)*PI)*.1) - 1.1,
		
        fF=step(uv.y,(fA+fW)+fP)*c,
		bF=step(uv.y,(-fA+bW)+fP)*c;

    COLOR =
		vec4((step(sdf,1.)-step(sdf,.9))+
		(fF+(clamp(bF-fF,0.,1.)*.8))+
		clamp(pow((sdf+.01)*
		((1.-(fF+bF))*c),5.),0.,1.));
		
}

