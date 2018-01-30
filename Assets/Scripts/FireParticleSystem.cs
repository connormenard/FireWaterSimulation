using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FireParticleSystem : MonoBehaviour {

    #region Structs
    /// <summary>
    /// Particle data
    /// This will be sent to both shaders.
    /// TODO: Currently prevPosition is unused,
    /// was intended to be used to draw lines rather than points
    /// </summary>
    protected struct FireParticle
    {
        public Vector3 position;
        public Vector3 velocity;
        public Vector3 startPosition;
        public Vector3 startVelocity;
        public Vector3 prevPosition;
        public float startTime;
    }
    #endregion
    #region Public Fields
    [Header("Setup")]
    //The location for the particles to spawn at
    //Doing it this way because the script has to be on the camera
    public Transform particleTransform;
    //Not-compute shader to render
    public Material particleShaderMaterial;
    //Compute shader to run data
    public ComputeShader shader;
    //Particle values
    [Header("Particle Data")]
    //Number of particles to be stored in memory on the GPU
    public int numParticles;
    //Rate at which to emit particles, lower=faster
    public float emissionTimeInterval;
    [Range(-1.0f, 1.0f)]
    public float startingXZvelocityMin;
    [Range(-1.0f, 1.0f)]
    public float startingXZvelocityMax;
    [Range(0.0f, 10.0f)]
    public float startingYVelocityMin;
    [Range(0.0f, 10.0f)]
    public float startingYVelocityMax;
    #endregion
    #region Private Fields
    //Size formula: 4 = 1 float
    //So for 4 vec3's we get 4*(3+3+3+3) = 48, for example
    //sizeof(Vector3) doesn't work, so we need this
    protected const int PARTICLE_SIZE = 64;
    protected int kernelID;
    protected ComputeBuffer computeBuffer;
    protected const int NUM_THREADS = 256;
    protected int numThreads;
    protected float particleRestartTime;
    #endregion
    #region Unity Defaults
    void Start () {
        //FIgure out how many threads we'll have to dispatch
        numThreads = Mathf.CeilToInt((float)numParticles / NUM_THREADS);
        //Prepare an array of particles to send to the GPU
        FireParticle[] particles = new FireParticle[numParticles];
        for (int i = 0; i < numParticles; i++)
        {
            particles[i].position = particleTransform.position;
            particles[i].velocity = new Vector3(
                Random.Range(startingXZvelocityMin, startingXZvelocityMax), 
                Random.Range(startingYVelocityMin, startingYVelocityMax), 
                Random.Range(startingXZvelocityMin, startingXZvelocityMax));
            particles[i].startPosition = particles[i].position;
            particles[i].startVelocity = particles[i].velocity;
            particles[i].prevPosition = particles[i].position;
            particles[i].startTime = i * emissionTimeInterval;
        }
        //Find out when we have to effectively restart the particle system
        particleRestartTime = emissionTimeInterval * (numParticles + 1);
        //Prepare the compute buffer
        //sizeof(Vector3) doesn't work? Doing a hacky solution instead...
        computeBuffer = new ComputeBuffer(numParticles, PARTICLE_SIZE);
        computeBuffer.SetData(particles);
        //Get the kernel
        kernelID = shader.FindKernel("FireCSMain");
        //Set the buffer data
        shader.SetBuffer(kernelID, "particleBuffer", computeBuffer);
        particleShaderMaterial.SetBuffer("particleBuffer", computeBuffer);
	}
    void Update () {
        //Update data in the compute shader
        shader.SetFloat("dt", Time.deltaTime);
        shader.SetFloat("totalTime", Time.fixedTime);
        shader.SetFloat("restartTime", particleRestartTime);
        //Tell the GPU to run the shader code
        shader.Dispatch(kernelID, numThreads, 1, 1);
	}
    void OnDestroy()
    {
        //Avoid GPU memory leaks!!!!!!!!!!!!
        if (computeBuffer != null)
            computeBuffer.Release();
    }
    /// <summary>
    /// Note: for this method to work the script must be attached to the camera
    /// </summary>
    void OnRenderObject()
    {
        //Prepare the fire material shader to draw
        particleShaderMaterial.SetPass(0); //only 1 pass so use index 0
        //Tell the GPU to draw the info from the shader
        //Question: how to get MeshTopology.Lines to work
        //Additional problem: rendering 4 vertices is a really bad and hacky solution to draw larger particles
        Graphics.DrawProcedural(MeshTopology.Points, 4, numParticles);
    }
    #endregion
}