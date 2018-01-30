using UnityEngine;
using System.Collections.Generic;
using System.Collections;

public class GameObjectSwitch : MonoBehaviour
{

    [System.Serializable]
    public class SwitchableArrays 
    {
        public GameObject[] gameObjects;
        public Behaviour[] behaviours;
    }

    public SwitchableArrays[] switchableGroups;
    public KeyCode toggleKey = KeyCode.C;
    public int currentlyActiveGroup;

    void Awake()
    {
        UpdateAllGroups();
    }

    void UpdateAllGroups()
    {
        for (int i = 0; i < switchableGroups.Length; i++)
        {
            if (i != currentlyActiveGroup)
                ChangeStates(i, false);
        }
        ChangeStates(currentlyActiveGroup, true);
    }

    void Update()
    {
        if (Input.GetKeyDown(toggleKey))
        {
            Toggle();
        }
    }

    void Toggle()
    {
        ChangeStates(currentlyActiveGroup, false);
        currentlyActiveGroup++;
        currentlyActiveGroup %= switchableGroups.Length;
        ChangeStates(currentlyActiveGroup, true);
    }

    void ChangeStates(int group, bool enable)
    {
        foreach (GameObject objectToEnable in switchableGroups[group].gameObjects)
        {
            objectToEnable.SetActive(enable);
        }
        foreach (Behaviour behaviourToEnable in switchableGroups[group].behaviours)
        {
            behaviourToEnable.enabled = enable;
        }
    }
}
