#include "ReShade.fxh"

// Uniforms for controlling scattering
uniform float LightScatteringIntensity <
    ui_type = "slider";
    ui_label = "Light Scattering Intensity";
    ui_min = 0.0; ui_max = 10.0;
    ui_tooltip = "Intensity of the light scattering effect";
> = 1.0;

uniform float ShadowScatteringIntensity <
    ui_type = "slider";
    ui_label = "Shadow Scattering Intensity";
    ui_min = -10.0; ui_max = 10.0;
    ui_tooltip = "Intensity of the shadow scattering effect";
> = 1.0;

uniform float ScatteringThreshold <
    ui_type = "slider";
    ui_label = "Scattering Threshold";
    ui_min = 0.0; ui_max = 1.0;
    ui_tooltip = "Threshold for scattering effect";
> = 0.5;

float3 ComputeScattering(float3 color, float intensity, float threshold)
{
    // Calculate the luminance of the color
    float luminance = dot(color, float3(0.299, 0.587, 0.114));
    // Calculate the scattering effect
    float scatter = max(0.0, luminance - threshold) * intensity;
    // Apply the scattering effect while preserving the original color
    return color + scatter * color;
}

float4 main(float4 position : SV_Position, float2 texcoord : TexCoord) : SV_Target
{
    float3 color = tex2D(ReShade::BackBuffer, texcoord).rgb;

    // Apply light scattering
    float3 lightScattering = ComputeScattering(color, LightScatteringIntensity, ScatteringThreshold);

    // Apply shadow scattering
    float3 shadowScattering = ComputeScattering(color, ShadowScatteringIntensity, ScatteringThreshold);

    // Combine light and shadow scattering
    float3 result = lightScattering - shadowScattering;

    // Increase color intensity based on scattering
    result = result * (1.0 + LightScatteringIntensity * 0.1) * (1.0 - ShadowScatteringIntensity * 0.1);

    // Clamp the result to ensure valid color range
    result = saturate(result);

    return float4(result, 1.0);
}

technique Scattering
{
    pass
    {
        VertexShader = PostProcessVS;
        PixelShader = main;
    }
}
