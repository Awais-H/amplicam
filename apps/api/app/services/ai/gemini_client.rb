module Ai
  class GeminiClient
    DEFAULT_MODEL = "gemini-2.5-flash".freeze
    ESCALATION_MODEL = "gemini-2.5-pro".freeze
    ENDPOINT_ROOT = "https://generativelanguage.googleapis.com".freeze

    def initialize(api_key: ENV.fetch("GEMINI_API_KEY"), connection: Faraday.new(url: ENDPOINT_ROOT))
      @api_key = api_key
      @connection = connection
    end

    def extract_receipt!(image_parts:, organization:, model: DEFAULT_MODEL)
      prompt = ReceiptExtractionPrompt.build(organization:)
      response = connection.post("/v1beta/models/#{model}:generateContent") do |request|
        request.params["key"] = api_key
        request.headers["Content-Type"] = "application/json"
        request.body = {
          systemInstruction: {
            parts: [{ text: ReceiptExtractionPrompt::SYSTEM_PROMPT }]
          },
          contents: [{ parts: image_parts + [{ text: prompt }] }],
          generationConfig: {
            responseMimeType: "application/json",
            responseJsonSchema: ReceiptExtractionPrompt.schema
          }
        }.to_json
      end

      raise "GeminiError: #{response.status}" unless response.success?

      body = JSON.parse(response.body)
      text = body.dig("candidates", 0, "content", "parts", 0, "text")
      parsed = JSON.parse(text)

      {
        model_name: model,
        raw_model_output: body,
        parsed_fields: parsed,
        reasoning_summary: parsed["reasoning_summary"],
        model_confidence: parsed["model_confidence"],
        token_usage: body["usageMetadata"] || {}
      }
    rescue JSON::ParserError => error
      raise "MalformedGeminiResponse: #{error.message}"
    end

    private

    attr_reader :api_key, :connection
  end
end

