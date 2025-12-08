from lib import read_context, write_response, get_script_args
from generated import DemoScriptResult

def main():
    context_file, response_file = get_script_args()

    try:
        # Read context
        context = read_context(context_file)

        # Process
        output = f"Echo: {context.input_data}"

        # Write response
        result = DemoScriptResult(output_data=output)
        write_response(response_file, result)

    except Exception as e:
        # Write error response
        result = DemoScriptResult(exception=str(e))
        write_response(response_file, result)
        raise


if __name__ == '__main__':
    main()
