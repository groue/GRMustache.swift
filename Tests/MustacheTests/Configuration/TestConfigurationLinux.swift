/**
 * Copyright IBM Corporation 2016
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 **/

class TestConfigurationLinux: TestConfigurationProtocol {
    var nsErrorTestsEnabled: Bool {
        // Error tests cause segmentation faults due to the following issue https://bugs.swift.org/browse/SR-585
        //TODO: return true once the issue is resolved
        return false
    }
    var localizerTestsEnabled: Bool {
        // Localizer tests are disabled due to issue https://bugs.swift.org/browse/SR-957
        //TODO: return true once the issue is resolved
        return false
    }
}
