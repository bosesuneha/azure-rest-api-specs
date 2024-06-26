import "@azure-tools/typespec-azure-core";
import "@typespec/rest";
import "./models.tsp";
import "../shared/routes.tsp";

using Azure.Core;
using TypeSpec.Versioning;
using TypeSpec.Rest;
using TypeSpec.Http;

namespace DevCenterService;

interface EnvironmentsOperations {
  #suppress "@azure-tools/typespec-azure-core/use-standard-operations" "Does not fit any standard operation pattern since Environment has a different path"
  @doc("Lists the environments for a project.")
  @route("/projects/{projectName}/environments")
  @get
  listAllEnvironments is Azure.Core.Foundations.Operation<
    {
      @doc("The DevCenter Project upon which to execute operations.")
      @path
      projectName: string;
    },
    EnvironmentListResult
  >;

  #suppress "@azure-tools/typespec-azure-core/use-standard-operations" "Need of reuse EnvironmentListResult"
  // This does fit in the ResourceList<Environment> but since listAllEnvironments also uses environment list result,
  // we can't use the standard operation here - it would not allow the use of EnvironmentListResult in the other operation.
  // error when using it in other operation: duplicate-type-name 'PagedEnvironment' (model EnvironmentListResult)
  @doc("Lists the environments for a project and user.")
  @route("/projects/{projectName}/users/{userId}/environments")
  @get
  listEnvironments is Azure.Core.Foundations.Operation<
    {
      @doc("The DevCenter Project upon which to execute operations.")
      @path
      projectName: string;

      @doc("The AAD object id of the user. If value is 'me', the identity is taken from the authentication context.")
      @path
      userId: string;
    },
    EnvironmentListResult
  >;

  @doc("Gets an environment")
  getEnvironment is StandardResourceOperations.ResourceRead<Environment>;

  #suppress "@azure-tools/typespec-azure-core/use-standard-operations" "Does not fit any standard operation pattern"
  //Can not use LongRunningCreateOrReplace because response is 200 or 201, but we only respond with 201"
  @doc("Creates or updates an environment.")
  @finalOperation(EnvironmentsOperations.getEnvironment)
  @pollingOperation(SharedOperations.getProjectOperationStatus)
  @route("/projects/{projectName}/users/{userId}/environments/{environmentName}")
  @put
  createOrUpdateEnvironment is Azure.Core.Foundations.Operation<
    {
      @doc("The DevCenter Project upon which to execute operations.")
      @path
      projectName: string;

      @doc("The AAD object id of the user. If value is 'me', the identity is taken from the authentication context.")
      @path
      userId: string;

      @doc("The name of the environment.")
      @path
      environmentName: string;

      @doc("Represents an environment.")
      @body
      body: Environment;
    },
    {
      @statusCode
      statusCode: 201;

      @pollingLocation
      @header("Operation-Location")
      operationLocation: string;

      @body body: Environment;
    }
  >;

  #suppress "@azure-tools/typespec-azure-core/use-standard-operations" "Does not fit any standard operation pattern"
  //Can not use LongRunningResourceDelete because response is 202 or error, but we also accept 204 response"
  @doc("Deletes an environment and all its associated resources")
  @pollingOperation(SharedOperations.getProjectOperationStatus)
  @route("/projects/{projectName}/users/{userId}/environments/{environmentName}")
  @delete
  deleteEnvironment is Azure.Core.Foundations.Operation<
    {
      @doc("The DevCenter Project upon which to execute operations.")
      @path
      projectName: string;

      @doc("The AAD object id of the user. If value is 'me', the identity is taken from the authentication context.")
      @path
      userId: string;

      @doc("The name of the environment.")
      @path
      environmentName: string;
    },
    {
      @statusCode
      statusCode: 202;

      @body body: OperationStatus;

      @header("Location")
      location: string;

      @pollingLocation
      @header("Operation-Location")
      operationLocation: string;
    } | {
      @statusCode
      statusCode: 204;
    }
  >;

  @doc("Lists all of the catalogs available for a project.")
  listCatalogs is StandardResourceOperations.ResourceList<Catalog>;

  @doc("Gets the specified catalog within the project")
  getCatalog is StandardResourceOperations.ResourceRead<Catalog>;

  #suppress "@azure-tools/typespec-azure-core/use-standard-operations" "Does not fit any standard operation pattern since EnvironmentDefinition has a different path"
  @doc("Lists all environment definitions available for a project.")
  @route("/projects/{projectName}/environmentDefinitions")
  @get
  listEnvironmentDefinitions is Azure.Core.Foundations.Operation<
    {
      @doc("The DevCenter Project upon which to execute operations.")
      @path
      projectName: string;
    },
    EnvironmentDefinitionListResult
  >;

  #suppress "@azure-tools/typespec-azure-core/use-standard-operations" "Need of reuse EnvironmentDefinitionListResult"
  // This does fit in the ResourceList<EnvironmentDefinition> but since listEnvironmentDefinitions also uses environment list result,
  // we can't use the standard operation here - it would not allow the use of EnvironmentDefinitionListResult in the other operation.
  // error when using it in other operation: duplicate-type-name 'PagedEnvironmentDefinition' (model EnvironmentDefinitionListResult)
  @doc("Lists all environment definitions available within a catalog.")
  @route("/projects/{projectName}/catalogs/{catalogName}/environmentDefinitions")
  @get
  listEnvironmentDefinitionsByCatalog is Azure.Core.Foundations.Operation<
    {
      @doc("The DevCenter Project upon which to execute operations.")
      @path
      projectName: string;

      @doc("The name of the catalog")
      @path
      catalogName: string;
    },
    EnvironmentDefinitionListResult
  >;

  @doc("Get an environment definition from a catalog.")
  getEnvironmentDefinition is StandardResourceOperations.ResourceRead<EnvironmentDefinition>;

  #suppress "@azure-tools/typespec-azure-core/use-standard-operations" "can not be represeted by using stand operations since there is no @key for EnvironmentType model"
  @doc("Lists all environment types configured for a project.")
  @route("/projects/{projectName}/environmentTypes")
  @get
  listEnvironmentTypes is Azure.Core.Foundations.Operation<
    {
      @doc("The DevCenter Project upon which to execute operations.")
      @path
      projectName: string;
    },
    EnvironmentTypeListResult
  >;
}
