swagger: '2.0'
info:
  title: Swagger Petstore
  description: Swagger Petstore
  license:
    name: Artistic License version 2.0
    url: 'http://dev.perl.org/licenses/artistic.html'
  termsOfService: 'http://www.example.com/terms'
  contact:
    name: API Support
    url: 'http://www.example.com/support'
    email: support@example.com
  version: '1.0'
host: www.example.com
basePath: /api/v1.0
schemes:
  - http
consumes:
  - application/json
produces:
  - application/json
x-mojo-around-action: 'Pets::authenticate_api_request'
paths:
  /:
    get:
      summary: API Info
      operationId: infoPets
      responses:
        '200':
          description: Expected response to a valid request
          schema:
            $ref: '#/definitions/Pets'
        default:
          description: unexpected error
          schema:
            $ref: '#/definitions/Error'
  /admin/ping:
    x-mojo-around-action: 'Pets::authenticate_api_request_admin'
    get:
      summary: Health Check
      operationId: pingPets
      responses:
        '200':
          description: Expected response to a valid request
          schema:
            $ref: '#/definitions/Pets'
        default:
          description: unexpected error
          schema:
            $ref: '#/definitions/Error'
  /admin/menu:
    x-mojo-around-action: 'Pets::authenticate_api_request_admin'
    get:
      summary: Admin Menu
      operationId: menuPets
      responses:
        '200':
          description: Expected response to a valid request
          schema:
            $ref: '#/definitions/Pets'
        default:
          description: unexpected error
          schema:
            $ref: '#/definitions/Error'
  /doc:
    get:
      summary: API Documentation
      operationId: docPets
      responses:
        '200':
          description: Expected response to a valid request
          schema:
            $ref: '#/definitions/Pets'
        default:
          description: unexpected error
          schema:
            $ref: '#/definitions/Error'
  /pets:
    get:
      summary: List all pets
      operationId: listPets
      tags:
        - pets
      parameters:
        - name: limit
          in: query
          description: How many items to return at one time (max 100)
          required: false
          type: integer
          format: int32
        - name: offset
          in: query
          description: How many items to skip from beginning (min 0)
          required: false
          type: integer
          format: int32
      responses:
        '200':
          description: An paged array of pets
          headers:
            x-next:
              type: string
              description: A link to the next page of responses
          schema:
            $ref: '#/definitions/Pets'
        default:
          description: unexpected error
          schema:
            $ref: '#/definitions/Error'
    put:
      summary: Create a pet
      operationId: createPets
      tags:
        - pets
      parameters:
        - name: name
          in: body
          description: Add pet by name
          required: true
          schema:
            $ref: '#/definitions/PetName'
      responses:
        '201':
          description: Expected response to a valid request
          schema:
            $ref: '#/definitions/Pets'
        '409':
          description: Null response
          schema:
            $ref: '#/definitions/Error'
        default:
          description: unexpected error
          schema:
            $ref: '#/definitions/Error'
  '/pets/{petId}':
    get:
      summary: Info for a specific pet
      operationId: showPetById
      tags:
        - pets
      parameters:
        - name: petId
          in: path
          required: true
          description: The id of the pet to retrieve
          type: string
      responses:
        '200':
          description: Expected response to a valid request
          schema:
            $ref: '#/definitions/Pets'
        default:
          description: unexpected error
          schema:
            $ref: '#/definitions/Error'
    delete:
      summary: Delete a specific pet
      operationId: DeletePetById
      tags:
        - pets
      parameters:
        - name: petId
          in: path
          required: true
          description: The id of the pet to delete
          type: string
      responses:
        '204':
          description: Expected response to a valid request
        '404':
          description: Not found
        default:
          description: unexpected error
          schema:
            $ref: '#/definitions/Error'
definitions:
  Pet:
    required:
      - id
      - name
    properties:
      id:
        type: integer
        format: int64
      name:
        type: string
      tag:
        type: string
  Pets:
    type: array
    items:
      $ref: '#/definitions/Pet'
  PetName:
    required:
      - name
    properties:
      name:
        type: string
  Error:
    required:
      - code
      - message
    properties:
      code:
        type: integer
        format: int32
      message:
        type: string

