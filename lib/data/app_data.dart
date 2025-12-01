const Map<String, dynamic> data = {
  "service": [
    {
      "serviceNameId": 1,
      "serviceName": "Doctor",
      "serviceTypes": [
        {
          "serviceTypeId": 101,
          "serviceType": "Eye care",
          "serviceList": [
            {
              "serviceListId": 1001,
              "name": "Dr. A Kumar",
              "serviceDetails": {"area": "Koramangala", "mobile": "9876543210"}
            },
            {
              "serviceListId": 1002,
              "name": "Dr. B Singh",
              "serviceDetails": {"area": "Indiranagar", "mobile": "9876543211"}
            }
          ]
        },
        {
          "serviceTypeId": 102,
          "serviceType": "heart care",
          "serviceList": [
            {
              "serviceListId": 1003,
              "name": "Dr. C Reddy (Cardiologist)",
              "serviceDetails": {"area": "Whitefield", "mobile": "9876543212"}
            }
          ]
        },
        {
          "serviceTypeId": 103,
          "serviceType": "kidney care",
          "serviceList": [
            {
              "serviceListId": 1004,
              "name": "Dr. C Reddy (Cardiologist)",
              "serviceDetails": {"area": "Whitefield", "mobile": "9876543212"}
            }
          ]
        }
      ]
    },
    {
      "serviceNameId": 2,
      "serviceName": "Hospital",
      "serviceTypes": [
        {
          "serviceTypeId": 201,
          "serviceType": "Multi-Specialty",
          "serviceList": [
            {
              "serviceListId": 2001,
              "name": "Apollo Hospital",
              "serviceDetails": {"area": "Jayanagar", "mobile": "9876543213"}
            },
            {
              "serviceListId": 2002,
              "name": "Manipal Hospital",
              "serviceDetails": {"area": "Hebbal", "mobile": "9876543214"}
            }
          ]
        },
        {
          "serviceTypeId": 202,
          "serviceType": "Eye Care",
          "serviceList": [
            {
              "serviceListId": 2003,
              "name": "Fortis Eye Care",
              "serviceDetails": {"area": "Bannerghatta", "mobile": "9876543215"}
            }
          ]
        }
      ]
    },
    {
      "serviceNameId": 3,
      "serviceName": "Emergency",
      "serviceTypes": [
        {
          "serviceTypeId": 301,
          "serviceType": "Ambulance",
          "serviceList": [
            {
              "serviceListId": 3001,
              "name": "Ambulance Service A",
              "serviceDetails": {"area": "BTM Layout", "mobile": "9876543216"}
            }
          ]
        },
        {
          "serviceTypeId": 302,
          "serviceType": "Fire",
          "serviceList": [
            {
              "serviceListId": 3002,
              "name": "Fire Station B",
              "serviceDetails": {"area": "Marathahalli", "mobile": "9876543217"}
            }
          ]
        },
        {
          "serviceTypeId": 303,
          "serviceType": "Disaster Response",
          "serviceList": [
            {
              "serviceListId": 3003,
              "name": "Disaster Unit C",
              "serviceDetails": {"area": "HSR Layout", "mobile": "9876543218"}
            }
          ]
        }
      ]
    }
  ],
  "product": [
    {
      "productNameId": 1,
      "productName": "Medical Equipment",
      "productTypes": [
        {
          "productTypeId": 101,
          "productType": "Diagnostic Tools",
          "productList": [
            {
              "productListId": 1001,
              "name": "Thermometer",
              "productDetails": {"area": "MG Road", "mobile": "9876500001"}
            },
            {
              "productListId": 1002,
              "name": "Blood Pressure Monitor",
              "productDetails": {"area": "Rajajinagar", "mobile": "9876500002"}
            }
          ]
        },
        {
          "productTypeId": 102,
          "productType": "Surgical Tools",
          "productList": [
            {
              "productListId": 1003,
              "name": "Scalpel Set",
              "productDetails": {"area": "Koramangala", "mobile": "9876500003"}
            }
          ]
        }
      ]
    },
    {
      "productNameId": 2,
      "productName": "Medicines",
      "productTypes": [
        {
          "productTypeId": 201,
          "productType": "Prescription Drugs",
          "productList": [
            {
              "productListId": 2001,
              "name": "Amoxicillin",
              "productDetails": {"area": "Indiranagar", "mobile": "9876500004"}
            },
            {
              "productListId": 2002,
              "name": "Metformin",
              "productDetails": {"area": "Jayanagar", "mobile": "9876500005"}
            }
          ]
        },
        {
          "productTypeId": 202,
          "productType": "OTC Drugs",
          "productList": [
            {
              "productListId": 2003,
              "name": "Paracetamol",
              "productDetails": {"area": "HSR Layout", "mobile": "9876500006"}
            }
          ]
        }
      ]
    },
    {
      "productNameId": 3,
      "productName": "Health Supplements",
      "productTypes": [
        {
          "productTypeId": 301,
          "productType": "Vitamins",
          "productList": [
            {
              "productListId": 3001,
              "name": "Vitamin C Tablets",
              "productDetails": {"area": "BTM Layout", "mobile": "9876500007"}
            }
          ]
        },
        {
          "productTypeId": 302,
          "productType": "Protein Powders",
          "productList": [
            {
              "productListId": 3002,
              "name": "Whey Protein",
              "productDetails": {"area": "Whitefield", "mobile": "9876500008"}
            }
          ]
        }
      ]
    }
  ]
};
