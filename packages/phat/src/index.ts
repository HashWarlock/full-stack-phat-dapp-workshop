// *** YOU ARE LIMITED TO THE FOLLOWING IMPORTS TO BUILD YOUR PHAT CONTRACT     ***
// *** ADDING ANY IMPORTS WILL RESULT IN ERRORS & UPLOADING YOUR CODE TO PHALA  ***
// *** NETWORK WILL FAIL. IF YOU WANT TO KNOW MORE, JOIN OUR DISCORD TO SPEAK   ***
// *** WITH THE PHALA TEAM AT https://discord.gg/5HfmWQNX THANK YOU             ***
// *** FOR DOCS ON HOW TO CUSTOMIZE YOUR PC 2.0 https://bit.ly/customize-pc-2-0 ***
import "@phala/pink-env";
import {decodeAbiParameters, encodeAbiParameters, parseAbiParameters} from "viem";

type HexString = `0x${string}`;
const encodeReplyAbiParams = 'uint respType, uint id, string[] greetings';
const decodeRequestAbiParams = 'uint id, address target';

function encodeReply(abiParams: string, reply: any): HexString {
    return encodeAbiParameters(parseAbiParameters(abiParams),
        reply
    );
}

function decodeRequest(abiParams: string, request: HexString): any {
    return decodeAbiParameters(parseAbiParameters(abiParams),
        request
    );
}

// Defined in OracleConsumerContract.sol
const TYPE_RESPONSE = 0;
const TYPE_ERROR = 2;

enum Error {
    BadRequestString = "BadRequestString",
    FailedToFetchData = "FailedToFetchData",
    FailedToDecode = "FailedToDecode",
    MalformedRequest = "MalformedRequest",
}

function errorToCode(error: Error): number {
    switch (error) {
        case Error.BadRequestString:
            return 1;
        case Error.FailedToFetchData:
            return 2;
        case Error.FailedToDecode:
            return 3;
        case Error.MalformedRequest:
            return 4;
        default:
            return 0;
    }
}
function stringToHex(str: string): string {
    var hex = "";
    for (var i = 0; i < str.length; i++) {
        hex += str.charCodeAt(i).toString(16);
    }
    return "0x" + hex;
}

function fetchApiStats(apiUrl: string, target: string): any {
    console.log("hi");
    let headers = {
        "Content-Type": "application/json",
        "User-Agent": "phat-contract"
    };
    const baseApiUrl = `${apiUrl}`
    const getTargetGreeting = JSON.stringify({ query:`query getTargetGreeting 
    { greetings(where: { sender_: { address: "${target}" }}) {
      id
      greeting
      premium
      value
      createdAt
      sender {
        address
        greetingCount
      }
    }}
  `});

    //
    // In Phat Contract runtime, we not support async/await, you need use `pink.batchHttpRequest` to
    // send http request. The Phat Contract will return an array of response.
    //
    let response = pink.batchHttpRequest(
        [
            { url: baseApiUrl, method: "POST", headers, body: stringToHex(getTargetGreeting), returnTextBody: true },
        ],
        10000 // Param for timeout in milliseconds. Your Phat Contract script has a timeout of 10 seconds
    )[0]; // Notice the [0]. This is important bc the `pink.batchHttpRequest` function expects an array of up to 5 HTTP requests.
    console.log(response);
    const responseBody = getResponseBody(response);
    let result = [];
    let count = 1;
    if (responseBody.data?.greetings) {
        for (const targetGreeting of responseBody.data?.greetings) {
            console.log(`[${count}]: ${targetGreeting.greeting}`);
            result.push(targetGreeting.greeting);
        }
    }

    return result;
}

function getResponseBody(response: any) {
    if (response.statusCode !== 200) {
        console.log(`Fail to read api with status code: ${response.statusCode}, error: ${response.error || response.body}}`);
        throw Error.FailedToFetchData;
    }
    if (typeof response.body !== "string") {
        throw Error.FailedToDecode;
    }
    console.log(response.body);
    return JSON.parse(response.body)
}

//
// Here is what you need to implemented for Phat Contract, you can customize your logic with
// JavaScript here.
//
// The Phat Contract will be called with two parameters:
//
// - request: The raw payload from the contract call `request` (check the `request` function in TestLensApiConsumerConract.sol).
//            In this example, it's a tuple of two elements: [requestId, profileId]
// - secrets: The custom secrets you set with the `config_core` function of the Action Offchain Rollup Phat Contract. In
//            this example, it just a simple text of the lens api url prefix. For more information on secrets, checkout the SECRETS.md file.
//
// Your returns value MUST be a hex string, and it will send to your contract directly. Check the `_onMessageReceived` function in
// OracleConsumerContract.sol for more details. We suggest a tuple of three elements: [successOrNotFlag, requestId, data] as
// the return value.
//
export default function main(request: HexString, secrets: string): HexString {
    console.log(`handle req: ${request}`);
    // Uncomment to debug the `secrets` passed in from the Phat Contract UI configuration.
    // console.log(`secrets: ${secrets}`);
    let requestId, targetAddress, parsedSecrets;
    try {
        [requestId, targetAddress] = decodeRequest(`${decodeRequestAbiParams}`, request);
        console.log(`[${requestId}]: ${targetAddress}`);
        parsedSecrets = JSON.parse(secrets);
    } catch (error) {
        console.info("Malformed request received");
        return encodeReply(encodeReplyAbiParams, [TYPE_ERROR, requestId, [error]]);
    }
    console.log(`Request received for profile ${targetAddress}`);
    try {
        const targetAddressGreetings = fetchApiStats(parsedSecrets.apiUrl, targetAddress.toLowerCase());
        console.log("response:", [TYPE_RESPONSE, requestId, targetAddressGreetings]);
        return encodeReply(encodeReplyAbiParams, [TYPE_RESPONSE, requestId, targetAddressGreetings]);
    } catch (error) {
        if (error === Error.FailedToFetchData) {
            throw error;
        } else {
            // otherwise tell client we cannot process it
            console.log("error:", [TYPE_ERROR, requestId, error]);
            return encodeReply(encodeReplyAbiParams, [TYPE_ERROR, requestId, [error]]);
        }
    }
}
