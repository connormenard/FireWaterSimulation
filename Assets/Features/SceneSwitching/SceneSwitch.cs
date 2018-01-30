using UnityEngine;
using System.Collections;
using UnityEngine.SceneManagement;

public class SceneSwitch : MonoBehaviour {

    public KeyCode key = KeyCode.L;
    void Update()
    {
        if (Input.GetKeyDown(key))
        {
            int sceneToLoadIndex = (SceneManager.GetActiveScene().buildIndex + 1) % SceneManager.sceneCountInBuildSettings;
            SceneManager.LoadScene(sceneToLoadIndex, LoadSceneMode.Single);
        }
    }
}
