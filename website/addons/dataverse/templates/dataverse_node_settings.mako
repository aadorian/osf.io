

<div id="dataverseScope" class="scripted">

    <h4 class="addon-title">
        Dataverse
        <small class="authorized-by">

            <span data-bind="if: nodeHasAuth">
                    authorized by <a data-bind="attr.href: urls().owner">
                        {{ownerName}}
                    </a>
                    <a data-bind="click: clickDeauth"
                        class="text-danger pull-right addon-auth">Deauthorize</a>
            </span>

            <span data-bind="if: showLinkDataverse">
                <a data-bind="click: importAuth" class="text-primary pull-right addon-auth">
                    Import Credentials
                </a>
            </span>

        </small>

    </h4>

    <div class="dataverse-settings" data-bind="if: nodeHasAuth && connected">

        <!-- The linked study -->
        <p>
            <strong>Current Study:</strong>
            <span data-bind="if: showLinkedStudy">
                <a data-bind="attr.href: savedStudyUrl()"> {{ savedStudyTitle }}</a> on
                <a data-bind="attr.href: savedDataverseUrl()"> {{ savedDataverseTitle }}</a>.
            </span>
            <span data-bind="ifnot: showLinkedStudy" class="text-muted">
                None
            </span>
        </p>

        <div data-bind="if: userIsOwner">
            <div class="row" data-bind="if: hasDataverses">
                <div class="col-md-6">
                    Dataverse:
                    <select class="form-control"
                            data-bind="options: dataverses,
                                       optionsValue: 'alias',
                                       optionsText: 'title',
                                       value: selectedDataverseAlias,
                                       event: {change: getStudies}">
                    </select>
                </div>

                <div class="col-md-6">
                    Study:
                    <div data-bind="if: showStudySelect">
                        <select class="form-control"
                                data-bind="options: studies,
                                           optionsValue: 'hdl',
                                           optionsText: 'title',
                                           value: selectedStudyHdl">
                        </select>
                    </div>
                    <div data-bind="if: showNoStudies">
                        <div class="text-info" style="padding-top: 8px">
                            No studies available.
                        </div>
                    </div>
                    <div data-bind="ifnot: loadedStudies">
                        <i class="icon-spinner icon-large icon-spin"
                           style="padding-bottom: 8px; padding-top: 8px"></i>
                        <span class="text-info">Retrieving studies...</span>
                    </div>
                </div>

            </div>

            <span data-bind="if: hasDataverses">

                <div class="padded">
                    <span data-bind="if: hasBadStudies" class="text-danger">
                        The following studies could not be loaded:
                        <ul data-bind="foreach: badStudies">
                            <li>
                                <a data-bind="text: hdl, attr.href: url" ></a>
                            </li>
                        </ul>
                    </span>

                    <button data-bind="enable: dataverseHasStudies, click: setInfo"
                            class="btn btn-primary pull-right">
                        Submit
                    </button>
                </div>

            </span>

            <div class="text-info" data-bind="ifnot: hasDataverses">
                Dataverse user {{ dataverseUsername }} does not currently have any released Dataverses.
            </div>

        </div>

    </div>

    <!-- Changed Credentials -->
    <div class="text-info dataverse-settings" data-bind="if: credentialsChanged">
        <span data-bind="if: userIsOwner">
            Your dataverse credentials may not be valid. Please re-enter your password.
        </span>
        <span data-bind="ifnot: userIsOwner">
            There was a problem connecting to the Dataverse with the given
            credentials.
        </span>
    </div>

    <!-- Input Credentials-->
    <form data-bind="if: showInputCredentials">
        <div class="form-group">
            <label for="dataverseUsername">Dataverse Username</label>
            <input class="form-control" name="dataverseUsername" data-bind="value: dataverseUsername"/>
        </div>
        <div class="form-group">
            <label for="dataversePassword">Dataverse Password</label>
            <input class="form-control" type="password" name="dataversePassword" data-bind="value: dataversePassword" />
        </div>
        <button data-bind="click: sendAuth" class="btn btn-success">
            Submit
        </button>
    </form>

    <!-- Flashed Messages -->
    <div class="help-block">
        <p data-bind="html: message, attr: {class: messageClass}"></p>
    </div>

</div>

<script>
    $script(['/static/addons/dataverse/dataverseNodeConfig.js'], function() {
        // Endpoint for Dataverse user settings
        var url = '${node["api_url"] + "dataverse/config/"}';
        // Start up the DataverseConfig manager
        var dataverse = new DataverseNodeConfig('#dataverseScope', url);
    });
</script>