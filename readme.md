# 🏥 MedBook API Documentation



## ☁️ Upload API

### POST /upload
- Upload image to Cloudinary.
- Form data: `image` (file)

```json
{
  "message": "Uploaded",
  "imageUrl": "https://res.cloudinary.com/.../your-image.jpg"
}
```


## 🔹 Hospital Type APIs

### GET /api/hospitalType
- Fetch all hospital types.
```json
{
  "result": "Success",
  "resultData": [
    { "id": 1, "name": "General", "imageUrl": "" }
  ]
}
```

### POST /api/hospitalType
- Add a new hospital type.
```json
{
  "name": "Dental",
  "imageUrl": "https://example.com/image.jpg"
}
```

### PUT /api/hospitalType/:id
- Update a hospital type.
```json
{
  "name": "Updated Name",
  "imageUrl": "https://example.com/new-image.jpg"
}
```

### DELETE /api/hospitalType/:id
- Delete a hospital type.

---

## 🔹 Hospital APIs

### GET /api/hospital/
- Fetch all hospitals.

### GET /api/hospital/:id
send hospital type Id to filter
```json
{
  "result": "Success",
  "resultData": [
    {
      "id": 1,
      "name": "Apollo",
      "imageUrl": "",
      "area": "",
      "mapLink": "",
      "phone": "",
      "hospitalTypeId": 1
    }
  ]
}
```

### POST /api/hospital
- Add a new hospital.
```json
{
  "name": "Apollo Hospital",
  "imageUrl": "https://example.com/image.jpg",
  "area": "Dubai",
  "mapLink": "https://maps.google.com/example",
  "phone": "+971-123456789",
  "hospitalTypeId": 1
}
```

### PUT /api/hospital/:id
- Update a hospital.
```json
{
  "name": "Updated Hospital",
  "imageUrl": "",
  "area": "",
  "mapLink": "",
  "phone": "",
  "hospitalTypeId": 1
}
```

### DELETE /api/hospital/:id
- Delete a hospital.

---


<!-- Doctors  -->

🩺 Doctor Type API Documentation
Base URL: http://<your-domain-or-ip>/api/doctorType
Replace <your-domain-or-ip> with localhost:3000 (or your actual deployment URL).

📘 GET /api/doctorType
Description:
Retrieve all doctor types.

Response:
json
Copy
Edit
{
  "result": "Success",
  "resultData": [
    {
      "id": 1,
      "name": "Cardiologist",
      "imageUrl": "https://example.com/image.jpg"
    }
  ]
}
📗 POST /api/doctorType
Description:
Add a new doctor type.

Request Body:
json
Copy
Edit
{
  "name": "Neurologist",
  "imageUrl": "https://example.com/neurologist.jpg"
}
Response:
json
Copy
Edit
{
  "result": "Success",
  "message": "Doctor type added",
  "resultData": {
    "id": 2,
    "name": "Neurologist",
    "imageUrl": "https://example.com/neurologist.jpg"
  }
}
📙 PUT /api/doctorType/:id
Description:
Update an existing doctor type by ID.

URL Params:
id (required): ID of the doctor type to update

Request Body:
json
Copy
Edit
{
  "name": "Neuro Specialist",
  "imageUrl": "https://example.com/updated-image.jpg"
}
Example:
bash
Copy
Edit
PUT /api/doctorType/2
Response:
json
Copy
Edit
{
  "result": "Success",
  "message": "Doctor type updated"
}
📕 DELETE /api/doctorType/:id
Description:
Delete a doctor type by ID.

URL Params:
id (required): ID of the doctor type to delete

Example:
bash
Copy
Edit
DELETE /api/doctorType/2
Response:
json
Copy
Edit
{
  "result": "Success",
  "message": "Doctor type deleted"
}
🔴 Error Response Example
json
Copy
Edit
{
  "result": "Failed",
  "message": "Error message here"
}


<!-- doctor api -->

# Doctor API Documentation

## Base Route
/api/doctor

---

### ✅ Get All Doctors (Filtered)
*GET* /api/doctor?doctorTypeId=&hospitalId=

Returns:
- doctorId
- doctorName
- imageUrl
- businessName
- location
- phone
- whatsapp
- rating

---

### ✅ Get Doctor By ID
*GET* /api/doctor/:id

Returns full details of the doctor.

---

### ✅ Add New Doctor
*POST* /api/doctor

Body:
json
{
  "doctorName": "Dr. Smith",
  "imageUrl": "https://...",
  "businessName": "ABC Clinic",
  "location": "Dubai",
  "phone": "+971-123456",
  "whatsapp": "+971-654321",
  "rating": 4.8,
  "experience": "10 years",
  "addressLine1": "Street 1",
  "addressLine2": "Near Hospital",
  "mapLink": "https://maps.google.com/...",
  "about": "About doctor...",
  "gallery": ["https://img1", "https://img2"],
  "youtubeLink": "https://youtube.com/...",
  "doctorTypeId": 1,
  "hospitalId": 1
}
---

### ✅ Update Doctor
*PUT* /api/doctor/:id

Body: Same as above.

---

### ✅ Delete Doctor
*DELETE* /api/doctor/:id

---

### ✅ Add Review
*POST* /api/doctor/:id/review

Body:
json
{
  "comment": "Very professional",
  "rating": 5
}


---

### ✅ Get Reviews
*GET* /api/doctor/:id/reviews




<!-- service -->

### base url https://medbook-backend-1.onrender.com/api



"home page "

/services/available-services


"2 nd page "

/services/service-types/${availableServiceId}


"3 nd page"

/services/services-by-type/${serviceTypeId}


"4 nd page"

/services/service/${id}


<!-- product -->
1
/products/availableProduct

2
/products/productType/byAvailableProduct/${availableProductId}


3
/products/product/byProductType/${productTypeId}

4
/products/product/${id}