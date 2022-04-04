import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:http/http.dart' as http;
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

String host = "https://trygo-server.herokuapp.com/payOrder/";

class TrygoForm extends StatefulWidget {
  const TrygoForm({Key? key}) : super(key: key);
  @override
  State<TrygoForm> createState() => _TrygoForm();
}

class _TrygoForm extends State<TrygoForm> {
  String? firstName, lastName, phone, email;
  bool isLoading = false;
  String? errMessage;

  void setLoading(bool val) {
    setState(() {
      isLoading = val;
    });
  }

  void payNow() async {
    if (firstName == null || firstName!.isEmpty) {
      setErrorMessage("First Name cannot be empty");
      return;
    }
    if (lastName == null || lastName!.isEmpty) {
      setErrorMessage("Last Name cannot be empty");
      return;
    }

    if (email == null || email!.isEmpty) {
      setErrorMessage("Email cannot be empty");
      return;
    }

    if (phone == null || phone!.isEmpty) {
      setErrorMessage("Phone cannot be empty");
      return;
    }

    setLoading(true);
    setErrorMessage(null);
    Map<String, dynamic> data = {
      "customer_name": "$firstName $lastName",
      "customer_phone": phone,
      "customer_email": email
    };

    Uri url = Uri.parse(host);

    try {
      var response = await http.post(url, body: data);

      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);

        if (data["status"] == "success") {
          html.window.open(data["payment_url"], '_self');
          return;
        }
        setErrorMessage(data["message"]);
      } else {
        setErrorMessage(response.body);
      }
      setLoading(false);
    } catch (e) {
      print(e.toString());
      setErrorMessage(e.toString());
      setLoading(false);
    }
  }

  void setValue(String fieldName, String value) {
    setState(() {
      switch (fieldName) {
        case "firstName":
          firstName = value;
          break;
        case "lastName":
          lastName = value;
          break;
        case "phone":
          phone = value;
          break;
        case "email":
          email = value;
          break;
      }
    });
  }

  void setErrorMessage(String? msg) {
    setState(() {
      errMessage = msg;
    });
  }

  @override
  Widget build(BuildContext context) {
    var deviceType = getDeviceType(MediaQuery.of(context).size);
    return Scaffold(
      appBar: appBar(),
      bottomNavigationBar:
          deviceType == DeviceScreenType.mobile ? null : footer(),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: Colors.grey[200],
        padding: deviceType == DeviceScreenType.mobile
            ? const EdgeInsets.all(15)
            : const EdgeInsets.all(20),
        child: ListView(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Builder(builder: (context) {
                  if (deviceType == DeviceScreenType.mobile) {
                    return const SizedBox(height: 40);
                  }
                  return const SizedBox(height: 50);
                }),
                const Text("Sign up",
                    style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.black)),
                const SizedBox(height: 20),
                const Text("Register with Trigo now",
                    style: TextStyle(fontSize: 18, color: Colors.black))
              ],
            ),
            SizedBox(height: errMessage == null ? 50 : 20),
            SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Builder(
                        builder: (context) {
                          if (errMessage == null) {
                            return Container();
                          }
                          return Column(
                            children: [
                              Text(errMessage ?? "",
                                  style: const TextStyle(
                                      color: Colors.red, fontSize: 14)),
                              const SizedBox(height: 20),
                            ],
                          );
                        },
                      ),
                      nameInput(),
                      const SizedBox(height: 30),
                      phoneInput(),
                      const SizedBox(height: 30),
                      emailInput(),
                      const SizedBox(height: 30),
                      isLoading
                          ? const CircularProgressIndicator(color: Colors.green)
                          : submitButton(),
                    ])),
            Builder(builder: (context) {
              if (deviceType == DeviceScreenType.mobile) {
                return Column(children: [const SizedBox(height: 40), footer()]);
              }
              return Container();
            })
          ],
        ),
      ),
    );
  }

  Widget submitButton() {
    return InkWell(
        onTap: () {
          payNow();
        },
        child: Container(
          height: 50,
          width: 200,
          decoration: const BoxDecoration(
            color: Colors.green,
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          child: const Center(
              child: Text("SUBMIT",
                  style: TextStyle(
                      color: Colors.white,
                      letterSpacing: 1.0,
                      fontSize: 16,
                      fontWeight: FontWeight.bold))),
        ));
  }

  Widget footer() {
    return Container(
      height: 100,
      color: Colors.black,
      padding: const EdgeInsets.all(20),
      child: const Center(
          child: Text(
              "© 2021 TryGo Service Private Limited All rights reserved",
              style: TextStyle(color: Colors.white, fontSize: 16))),
    );
  }

  AppBar appBar() {
    var deviceType = getDeviceType(MediaQuery.of(context).size);
    return AppBar(
      backgroundColor: Colors.green,
      leading: const Icon(
        Icons.arrow_back,
        color: Colors.white,
      ),
      actions: (deviceType == DeviceScreenType.mobile)
          ? null
          : [
              Container(
                  padding: const EdgeInsets.all(15),
                  child: Row(children: const [
                    Icon(Icons.email, color: Colors.yellow),
                    SizedBox(width: 10),
                    Text("support@trygoservice.com",
                        style: TextStyle(fontSize: 20))
                  ])),
              Container(
                  padding: const EdgeInsets.all(15),
                  child: Row(
                    children: const [
                      Icon(Icons.phone, color: Colors.yellow),
                      SizedBox(width: 10),
                      Text("(+91) 6366456876", style: TextStyle(fontSize: 20)),
                    ],
                  )),
              const SizedBox(width: 20),
            ],
      title: const Text(
        "Trygo",
        style: TextStyle(fontSize: 24),
      ),
    );
  }

  Widget emailInput() {
    var deviceType = getDeviceType(MediaQuery.of(context).size);
    return SizedBox(
        width: deviceType == DeviceScreenType.mobile ? 300 : 620,
        child: TextField(
          onChanged: (txt) {
            setValue("email", txt);
          },
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
              border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black)),
              fillColor: Colors.white,
              filled: true,
              labelText: "Email",
              hintText: "Ex : john@example.com",
              labelStyle: TextStyle(fontSize: 16, color: Colors.black)),
        ));
  }

  Widget phoneInput() {
    var deviceType = getDeviceType(MediaQuery.of(context).size);
    return SizedBox(
        width: deviceType == DeviceScreenType.mobile ? 300 : 620,
        child: TextField(
          onChanged: (txt) {
            setValue("phone", txt);
          },
          keyboardType: TextInputType.number,
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.digitsOnly
          ],
          maxLength: 10,
          decoration: const InputDecoration(
              border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black)),
              fillColor: Colors.white,
              filled: true,
              labelText: "Phone",
              hintText: "Ex:9111922284",
              labelStyle: TextStyle(fontSize: 16, color: Colors.black)),
        ));
  }

  Widget nameInput() {
    var deviceType = getDeviceType(MediaQuery.of(context).size);

    Widget firstNameInput() {
      return SizedBox(
          width: 300,
          child: TextField(
            onChanged: (txt) {
              setValue("firstName", txt);
            },
            decoration: const InputDecoration(
                border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black)),
                fillColor: Colors.white,
                filled: true,
                labelText: "First Name",
                labelStyle: TextStyle(fontSize: 16, color: Colors.black)),
          ));
    }

    Widget lastNameInput() {
      return SizedBox(
          width: 300,
          child: TextField(
            onChanged: (txt) {
              setValue("lastName", txt);
            },
            decoration: const InputDecoration(
                border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black)),
                fillColor: Colors.white,
                filled: true,
                labelText: "Last Name",
                labelStyle: TextStyle(fontSize: 16, color: Colors.black)),
          ));
    }

    if (deviceType == DeviceScreenType.mobile) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          firstNameInput(),
          const SizedBox(height: 20),
          lastNameInput()
        ],
      );
    }

    return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          firstNameInput(),
          const SizedBox(width: 20),
          lastNameInput()
        ]);
  }
}