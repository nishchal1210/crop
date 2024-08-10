import android.os.AsyncTask;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;
import com.olamaps.sdk.Platform;
import com.olamaps.sdk.PlatformConfig;
import com.olamaps.sdk.PlacesClient;
import com.olamaps.sdk.DirectionsClient;
import com.olamaps.sdk.model.DirectionsRequest;
import com.olamaps.sdk.model.DirectionsResponse;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.RequestBody;
import okhttp3.Response;
import okhttp3.MediaType;

import org.json.JSONObject;

import java.io.IOException;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "com.example.crop/ola_maps";
    private PlatformConfig config;
    private PlacesClient placesClient;
    private DirectionsClient directionsClient;
    private String bearerToken;

    @Override
    public void configureFlutterEngine(FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);

        config = PlatformConfig.newBuilder()
            .setClientId("20098a3e-6493-40bb-85aa-430731f9eedd")
            .setClientSecret("4WRWy066fuyud4nUtMW6jPLNc3Rp73fv")
            .setRetryMode(PlatformConfig.RetryMode.STANDARD)
            .setMaxRetryAttempts(3)
            .build();

        // Get bearer token
        new OAuthTask().execute();

        placesClient = Platform.getPlacesClient(config);
        directionsClient = Platform.getDirectionsClient(config);

        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
            .setMethodCallHandler(
                (call, result) -> {
                    if (call.method.equals("getDirections")) {
                        String origin = call.argument("origin");
                        String destination = call.argument("destination");

                        DirectionsRequest directionsRequest = DirectionsRequest.newBuilder()
                            .setOrigin(origin)
                            .setDestination(destination)
                            .build();

                        // Make an async task to handle the API call
                        new DirectionsTask(result, directionsRequest).execute();
                    } else {
                        result.notImplemented();
                    }
                }
            );
    }

    private class OAuthTask extends AsyncTask<Void, Void, String> {
        @Override
        protected String doInBackground(Void... voids) {
            OkHttpClient client = new OkHttpClient();
            MediaType mediaType = MediaType.parse("application/x-www-form-urlencoded");
            RequestBody body = RequestBody.create(mediaType, "grant_type=client_credentials&client_id=PLACE_YOUR_CLIENT_ID&client_secret=PLACE_YOUR_CLIENT_SECRET_HERE");
            Request request = new Request.Builder()
                .url("https://auth.olamaps.com/oauth2/token")
                .post(body)
                .build();
    
            try {
                Response response = client.newCall(request).execute();
                if (response.isSuccessful()) {
                    JSONObject jsonObject = new JSONObject(response.body().string());
                    return jsonObject.getString("access_token");
                }
            } catch (IOException | JSONException e) {
                e.printStackTrace();
            }
    
            return null;
        }
    
        @Override
        protected void onPostExecute(String token) {
            if (token != null) {
                bearerToken = token;
            } else {
                Log.e("OAuthTask", "Failed to retrieve token.");
            }
        }
    }
    
    private class DirectionsTask extends AsyncTask<Void, Void, String> {
        private MethodChannel.Result result;
        private DirectionsRequest directionsRequest;
    
        DirectionsTask(MethodChannel.Result result, DirectionsRequest directionsRequest) {
            this.result = result;
            this.directionsRequest = directionsRequest;
        }
    
        @Override
        protected String doInBackground(Void... voids) {
            if (bearerToken == null) {
                return null; // Token is not yet available
            }
    
            OkHttpClient client = new OkHttpClient();
            Request request = new Request.Builder()
                .url("https://maps.olamaps.com/directions")
                .addHeader("Authorization", "Bearer " + bearerToken)
                .post(RequestBody.create(
                    MediaType.parse("application/json"),
                    directionsRequest.toString()
                ))
                .build();
    
            try {
                Response response = client.newCall(request).execute();
                if (response.isSuccessful()) {
                    return response.body().string();
                }
            } catch (IOException e) {
                e.printStackTrace();
            }
    
            return null;
        }
    
        @Override
        protected void onPostExecute(String directions) {
            if (directions != null) {
                result.success(directions);
            } else {
                result.error("UNAVAILABLE", "Directions not available.", null);
            }
        }
    }
    