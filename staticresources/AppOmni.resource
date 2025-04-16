{
  "recordTypeMap": {},
  "RecordSetBundles": [
    {
      "Records": [
        {
          "attributes": {
            "type": "copado__JobTemplate__c",
            "url": "/services/data/v62.0/sobjects/copado__JobTemplate__c/a0wHs00000Oa16jIAB"
          },
          "copado__ApiName__c": "App_Omni_Org_Scan_1",
          "copado__Type__c": "Custom",
          "copado__Version__c": 1,
          "Id": "a0wHs00000Oa16jIAB",
          "LastReferencedDate": "2024-11-18T20:44:06.000+0000",
          "LastViewedDate": "2024-11-18T20:44:06.000+0000",
          "Name": "App Omni Org Scan"
        }
      ],
      "ObjectType": "copado__JobTemplate__c"
    },
    {
      "Records": [
        {
          "attributes": {
            "type": "copado__JobStep__c",
            "url": "/services/data/v62.0/sobjects/copado__JobStep__c/a0vHs00000IT8cMIAT"
          },
          "copado__ApiName__c": "App_Omni_Org_Scan_1_App_Omni_1",
          "copado__ConfigJson__c": "{\"functionName\":\"AppOmni_Policy_Scan\",\"parameters\":[{\"name\":\"AOTenantURL\",\"value\":\"\",\"required\":true},{\"name\":\"AOPolicyID\",\"value\":\"\",\"required\":true},{\"name\":\"ACCESS_TOKEN\",\"value\":\"\",\"required\":true},{\"name\":\"REFRESH_TOKEN\",\"value\":\"\",\"required\":true},{\"name\":\"OAUTH_CLIENT_ID\",\"value\":\"\",\"required\":true},{\"name\":\"OAUTH_CLIENT_SECRET\",\"value\":\"\",\"required\":true}]}",
          "copado__CustomType__c": "Function",
          "copado__IsSkipped__c": false,
          "copado__JobTemplate__c": "a0wHs00000Oa16jIAB",
          "copado__Order__c": 1,
          "copado__Type__c": "Function",
          "Id": "a0vHs00000IT8cMIAT",
          "Name": "App Omni"
        }
      ],
      "ObjectType": "copado__JobStep__c"
    },
    {
      "Records": [
        {
          "attributes": {
            "type": "copado__Function__c",
            "url": "/services/data/v62.0/sobjects/copado__Function__c/a0nHs00000QCsvuIAD"
          },
          "copado__API_Name__c": "AppOmni_Policy_Scan",
          "copado__Image_Name__c": "us.gcr.io/copado/copado-function-core:v1",
          "copado__Options__c": "[ ]",
          "copado__Parameters__c": "[ {\n  \"required\" : true,\n  \"name\" : \"AOTenantURL\",\n  \"defaultValue\" : \"\"\n}, {\n  \"required\" : true,\n  \"name\" : \"AOPolicyID\",\n  \"defaultValue\" : \"\"\n}, {\n  \"required\" : true,\n  \"name\" : \"ACCESS_TOKEN\",\n  \"defaultValue\" : \"\"\n}, {\n  \"required\" : true,\n  \"name\" : \"REFRESH_TOKEN\",\n  \"defaultValue\" : \"\"\n}, {\n  \"required\" : true,\n  \"name\" : \"OAUTH_CLIENT_ID\",\n  \"defaultValue\" : \"\"\n}, {\n  \"required\" : true,\n  \"name\" : \"OAUTH_CLIENT_SECRET\",\n  \"defaultValue\" : \"\"\n} ]",
          "copado__Script__c": "#!/usr/bin/env python\nimport os\nimport json\nimport requests\nimport time\n\nTEMP_CUSTOMER_INSTANCE=os.environ['AOTenantURL']\nTEMP_ACCESS_TOKEN=os.environ['ACCESS_TOKEN']\nTEMP_REFRESH_TOKEN=os.environ['REFRESH_TOKEN']\nTEMP_OAUTH_CLIENT_ID=os.environ['OAUTH_CLIENT_ID']\nTEMP_OAUTH_CLIENT_SECRET=os.environ['OAUTH_CLIENT_SECRET']\nTEMP_AOPOLICY_ID=os.environ['AOPolicyID']\n\n\nclass API:\n    \"\"\"\n    Class representing API calls and queries for AppOmni Tenant.\n    Utilizes requests to send GET, POST, and PATCH methods to API endpoint URLs\n    \"\"\"\n\n    def __init__(self, tenant='', api_version='', header=None):\n        self.tenant = tenant\n        self.api_version = api_version\n        self.header = header\n\n    def api_query(self, command, payload=None):\n        if payload is None:\n            payload = {}\n\n        base_url = f\"https://{self.tenant}/{self.api_version}/{command}\"\n        query_response = requests.get(base_url, headers=self.header, data=payload)\n        return query_response\n\n    def api_call(self, command, payload=None):\n        if payload is None:\n            payload = {}\n\n        base_url = f\"https://{self.tenant}/{self.api_version}/{command}\"\n        call_response = requests.post(base_url, headers=self.header, data=payload)\n        return call_response\n\n\nclass APIClient:\n    \"\"\"\n    APIClient encapsulates everything a user needs to do for communicating with AppOmni Public API Endpoints\n    \"\"\"\n\n    def __init__(self, tenant=None, access_token=None, refresh_token=None, client_id=None, client_secret=None):\n        self.tenant = tenant\n        self.access_token = access_token\n        self.refresh_token = refresh_token\n        self.client_id = client_id\n        self.client_secret = client_secret\n        self.oauth_token_path = \"/oauth/token/\"\n        self.token_check_path = \"/api/v1/core/user/my/\"\n        self.api_version = \"api/v1\"\n        self.header = self.get_access_token_header()\n        self.obj_API = API(self.tenant, self.api_version, self.header)\n\n    def __enter__(self):\n        return self\n\n    def __exit__(self, exc_type, exc_value, traceback):\n        \"\"\"destructor\"\"\"\n        return self\n\n    def get_new_access_token(self):\n        \"\"\"\n        Leverages refresh token, client ID and secret to receive new access token\n        :return: access token\n        \"\"\"\n        token_url = f\"https://{self.tenant}{self.oauth_token_path}\"\n        data = {\n            \"grant_type\": \"refresh_token\",\n            \"refresh_token\": self.refresh_token,\n            \"client_id\": self.client_id,\n            \"client_secret\": self.client_secret,\n        }\n        headers = {\"Accept\": \"application/json\"}\n\n        response = requests.post(token_url, headers=headers, data=data)\n        if response.status_code != 200:\n            raise Exception(f\"Unable to refresh oauth token for {self.tenant}\")\n        content = response.json()\n\n        return content[\"access_token\"]\n\n    def get_access_token_header(self):\n        \"\"\"\n        checks access tokens validity.\n        :return: headers of type dictionary containing Bearer access token\n        \"\"\"\n        token_check_url = f\"https://{self.tenant}{self.token_check_path}\"\n        header = {\n            \"Authorization\": f\"Bearer {self.access_token}\"\n        }\n\n        response = requests.get(token_check_url, headers=header)\n        if response.status_code != 200:\n            print(f\"Refreshing access token for {self.tenant}\")\n            header = {\n                \"Authorization\": f\"Bearer {self.get_new_access_token()}\"\n            }\n\n        return header\n\n    def scan_policy(self, policyid: str):\n        \"\"\"\n        Initiates/Starts a policy scan based on policy id number\n        :param policyid: numerical string representing an AppOmni Policy ID number\n        :return: APIResponse Object of scan initiation information\n        \"\"\"\n        return self.obj_API.api_call(f\"core/policy/{policyid}/scan/\")\n\n    def get_policy_scan_status(self, externalid: str):\n        \"\"\"\n        Provides details of policy scan status\n        :param externalid: numerical string representing a policy scan external id.\n        Externalid found in scan_policy response\n        :return: APIResponse Object of scan status details\n        \"\"\"\n        return self.obj_API.api_query(f\"core/policyassessment/check_status?external_id={externalid}\")\n\n\ndef main():\n    with APIClient(TEMP_CUSTOMER_INSTANCE, TEMP_ACCESS_TOKEN, TEMP_REFRESH_TOKEN, TEMP_OAUTH_CLIENT_ID,\n                   TEMP_OAUTH_CLIENT_SECRET) as client:\n\n        promotion = None\n        policyid = TEMP_AOPOLICY_ID\n\n        call_response = client.scan_policy(policyid)\n        if call_response.ok:\n            external_id = call_response.json()['external_id']\n            print(external_id)\n        else:\n            print(\"Policy Scan could not be initiated. HTTP Status Code {call_response.status_code}\")\n            promotion = False\n            return promotion\n\n        completion_status = None\n\n        while completion_status is None:\n            scan_status_rr = client.get_policy_scan_status(external_id)\n            if scan_status_rr.json()['complete'] is True:\n                completion_status = scan_status_rr.json()['completion_status']\n\n            if completion_status is None:\n                time.sleep(10)\n            else:\n                open_issues = int(scan_status_rr.json()[\"open_issues\"])\n                if open_issues > 0:\n                    promotion = False\n                elif open_issues == 0:\n                    promotion = True\n        print(promotion)\n        return promotion\n\n\nif __name__ == '__main__':\n    promotion_decision = main()\n    if promotion_decision:\n        os.system('copado -p \"AppOmni Scan Did Not Return Open Issues.  Scan pass Successful\"')\n        exit(0)\n    else:\n        os.system('copado -p \"Failed\" -e \"AppOmni Scan Returned Open Issues.  Failed to pass scan.\"')\n        exit(1)",
          "copado__Timeout__c": 30,
          "copado__Type__c": "Custom",
          "copado__Worker_Size__c": "M",
          "Id": "a0nHs00000QCsvuIAD",
          "LastReferencedDate": "2024-11-18T16:36:27.000+0000",
          "LastViewedDate": "2024-11-18T16:36:27.000+0000",
          "Name": "AppOmni Policy Scan"
        }
      ],
      "ObjectType": "copado__Function__c"
    }
  ],
  "blobsByUID": {}
}