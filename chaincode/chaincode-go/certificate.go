package main

import (
	"encoding/json"
	"fmt"
	"strconv"

	"github.com/hyperledger/fabric-contract-api-go/contractapi"
)

// SmartContract provides functions for managing a car
type SmartContract struct {
	contractapi.Contract
}

type IdCounter struct {
	Counter int `json:"counter"`
}

type Certificate struct {
	ID         int    `json:"id"`
	StudentID  int    `json:"student_id"`
	University string `json:"university"`
	College    string `json:"college"`
	Course     string `json:"course"`
	IssueDate  string `json:"issue_date"`
}

type Student struct {
	ID           int           `json:"id"`
	Name         string        `json:"name"`
	Email        string        `json:"email"`
	Phone        string        `json:"phone"`
	Certificates []Certificate `json:"certificates"`
}

// QueryResult structure used for handling result of query
type QueryResult struct {
	Key    string `json:"Key"`
	Record *Certificate
}

// InitLedger adds a base set of cars to the ledger
func (s *SmartContract) InitLedger(ctx contractapi.TransactionContextInterface) error {

	//Add code to initilize both StudentIdCounter and CertificateIdCounter to 0
	/*
		students := []StudentDetail{
			StudentDetail{Make: "Toyota", Model: "Prius", Colour: "blue", Owner: "Tomoko"},
			StudentDetail{Make: "Ford", Model: "Mustang", Colour: "red", Owner: "Brad"},
		}

		for i, student := range students {
			studentAsBytes, _ := json.Marshal(student)
			err := ctx.GetStub().PutState(strconv.Itoa(i), studentAsBytes)

			if err != nil {
				return fmt.Errorf("Failed to put to world state. %s", err.Error())
			}
		}*/
	studentIdCounter := IdCounter{
		Counter: 0,
	}
	studentIdCounterAsBytes, _ := json.Marshal(studentIdCounter)
	ctx.GetStub().PutState("studentIdCounter", studentIdCounterAsBytes)

	certificateIdCounter := IdCounter{
		Counter: 0,
	}
	certificateIdCounterAsBytes, _ := json.Marshal(certificateIdCounter)
	ctx.GetStub().PutState("certificateIdCounter", certificateIdCounterAsBytes)

	return nil
}

// CreateCar adds a new car to the world state with given details
func (s *SmartContract) CreateStudent(ctx contractapi.TransactionContextInterface, name string, email string, phone string) error {

	studentIdCounter, err := s.QueryIdCounter(ctx, "studentIdCounter")
	if err != nil {
		return err
	}
	//call QueryIdCounter with key "studentIdCounter" to fetch the latest StudentId

	//Increase it by 1 and then save the state.
	var latestId = studentIdCounter.Counter
	var newStudentId = latestId + 1

	updatedStudentIdCounter := IdCounter{
		Counter: newStudentId,
	}

	studentIdCounterAsBytes, _ := json.Marshal(updatedStudentIdCounter)

	ctx.GetStub().PutState("studentIdCounter", studentIdCounterAsBytes)

	//var emptySlice []Certificate{}

	student := Student{
		ID:           newStudentId,
		Name:         name,
		Email:        email,
		Phone:        phone,
		Certificates: []Certificate{},
	}

	studentAsBytes, _ := json.Marshal(student)

	return ctx.GetStub().PutState(strconv.Itoa(newStudentId), studentAsBytes)
}

// QueryCar returns the car stored in the world state with given id
func (s *SmartContract) QueryStudent(ctx contractapi.TransactionContextInterface, studentId string) (*Student, error) {
	studentAsBytes, err := ctx.GetStub().GetState(studentId)

	if err != nil {
		return nil, fmt.Errorf("Failed to read from world state. %s", err.Error())
	}

	if studentAsBytes == nil {
		return nil, fmt.Errorf("%s does not exist", studentId)
	}

	student := new(Student)
	_ = json.Unmarshal(studentAsBytes, student)

	return student, nil
}

// QueryCar returns the car stored in the world state with given id
func (s *SmartContract) QueryCertificate(ctx contractapi.TransactionContextInterface, studentId string, certificateId string) (*Certificate, error) {
	studentAsBytes, err := ctx.GetStub().GetState(studentId)

	if err != nil {
		return nil, fmt.Errorf("Failed to read from world state. %s", err.Error())
	}

	if studentAsBytes == nil {
		return nil, fmt.Errorf("%s does not exist", studentId)
	}

	student := new(Student)
	_ = json.Unmarshal(studentAsBytes, student)

	certificateRet := new(Certificate)
	intCertificateId, err := strconv.Atoi(certificateId)
	if err != nil {
		return nil, err
	}

	for i, certificate := range student.Certificates {
		fmt.Println(i)
		if certificate.ID == intCertificateId {
			certificateRet.ID = certificate.ID
			certificateRet.StudentID = certificate.StudentID
			certificateRet.University = certificate.University
			certificateRet.College = certificate.College
			certificateRet.Course = certificate.Course
			certificateRet.IssueDate = certificate.IssueDate
		}
	}

	return certificateRet, nil
}

// CreateCar adds a new car to the world state with given details
func (s *SmartContract) CreateCertificate(ctx contractapi.TransactionContextInterface, studentId string, university string, college string, course string, issueDate string) error {

	student, err := s.QueryStudent(ctx, studentId)
	if err != nil {
		return err
	}
	//call QueryIdCounter with key "studentIdCounter" to fetch the latest StudentId

	//Increase it by 1 and then save the state.
	certificateIdCounter, err := s.QueryIdCounter(ctx, "certificateIdCounter")
	if err != nil {
		return err
	}
	//call QueryIdCounter with key "studentIdCounter" to fetch the latest StudentId

	//Increase it by 1 and then save the state.
	var latestId = certificateIdCounter.Counter
	var newCertificateId = latestId + 1

	updatedCertificateIdCounter := IdCounter{
		Counter: newCertificateId,
	}

	certificateIdCounterAsBytes, _ := json.Marshal(updatedCertificateIdCounter)

	ctx.GetStub().PutState("certificateIdCounter", certificateIdCounterAsBytes)

	intStudentId, err := strconv.Atoi(studentId)
	if err != nil {
		return err
	}

	certificate := Certificate{
		ID:         newCertificateId,
		StudentID:  intStudentId,
		University: university,
		College:    college,
		Course:     course,
		IssueDate:  issueDate,
	}

	student.Certificates = append(student.Certificates, certificate)

	studentAsBytes, _ := json.Marshal(student)

	return ctx.GetStub().PutState(studentId, studentAsBytes)
}

func (s *SmartContract) QueryIdCounter(ctx contractapi.TransactionContextInterface, counterKey string) (*IdCounter, error) {
	counterAsBytes, err := ctx.GetStub().GetState(counterKey)

	if err != nil {
		return nil, fmt.Errorf("Failed to read from world state. %s", err.Error())
	}

	if counterAsBytes == nil {
		return nil, fmt.Errorf("%s does not exist", counterKey)
	}

	counterStruct := new(IdCounter)
	_ = json.Unmarshal(counterAsBytes, counterStruct)

	return counterStruct, nil
}

func main() {

	chaincode, err := contractapi.NewChaincode(new(SmartContract))

	if err != nil {
		fmt.Printf("Error create fabcar chaincode: %s", err.Error())
		return
	}

	if err := chaincode.Start(); err != nil {
		fmt.Printf("Error starting fabcar chaincode: %s", err.Error())
	}
}
