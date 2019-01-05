module AddTeamMemberMenuView exposing (modal, update)

import AddTeamMemberMenu
import AppModel
import AppMsg
import AppSync
import AttributeBuilder
import Bulma
import Decoders
import Html.Styled as Html
import Html.Styled.Attributes as Attributes
import Html.Styled.Events as Events
import Json.Decode


modal : AddTeamMemberMenu.Menu -> Html.Html AppMsg.Msg
modal model =
    let
        title =
            "Add Team Member"

        body =
            Html.div
                []
                [ Bulma.labelledField
                    "email"
                    [ Bulma.textInput
                        [ Attributes.placeholder "email"
                        , Attributes.value model.email
                        , Events.onInput (AppMsg.AddTeamMemberMenuMsg << AppMsg.SetEmail)
                        ]
                    ]
                ]

        footer =
            [ Bulma.button
                ([ Bulma.isSuccessClass, Events.onClick (AppMsg.AddTeamMemberMenuMsg AppMsg.SaveTeamMember) ]
                    |> AttributeBuilder.addIf
                        (model.email == "")
                        [ Attributes.disabled True ]
                    |> AttributeBuilder.addIf
                        (model.state == AddTeamMemberMenu.Pending)
                        [ Bulma.isLoadingClass ]
                )
                "invite"
            , Html.span
                ([ Bulma.helpClass
                 , Bulma.isDangerClass
                 ]
                    |> AttributeBuilder.addIf (not <| model.state == AddTeamMemberMenu.Error) [ Bulma.isInvisibleClass ]
                )
                [ Html.text "Something went wrong, try again later." ]
            ]
    in
    Bulma.modal model.isOpen title (AppMsg.AddTeamMemberMenuMsg AppMsg.ToggleAddTeamMemberMenu) body footer


update : AppMsg.AddTeamMemberMenuMsg -> AppModel.Model -> ( AppModel.Model, Cmd AppMsg.Msg )
update msg model =
    case msg of
        AppMsg.ToggleAddTeamMemberMenu ->
            ( model.addTeamMemberMenu |> AddTeamMemberMenu.toggle |> AppModel.asAddTeamMemberMenu model, Cmd.none )

        AppMsg.SetEmail email ->
            ( model.addTeamMemberMenu |> AddTeamMemberMenu.setEmail email |> AppModel.asAddTeamMemberMenu model, Cmd.none )

        AppMsg.SaveTeamMember ->
            ( model.addTeamMemberMenu |> AddTeamMemberMenu.setState AddTeamMemberMenu.Pending |> AppModel.asAddTeamMemberMenu model
            , AppSync.send
                (AppMsg.AddTeamMemberMenuMsg << AppMsg.InviteTeamMemberResponse)
                (AppMsg.InviteTeamMemberRequest model.addTeamMemberMenu.email)
            )

        AppMsg.InviteTeamMemberResponse (Ok json) ->
            case Json.Decode.decodeValue Decoders.userDecoder json of
                Err _ ->
                    ( model.addTeamMemberMenu |> AddTeamMemberMenu.setState AddTeamMemberMenu.Error |> AppModel.asAddTeamMemberMenu model, Cmd.none )

                Ok user ->
                    ( AddTeamMemberMenu.init |> AppModel.asAddTeamMemberMenu (AppModel.addTeamMember user model), Cmd.none )

        AppMsg.InviteTeamMemberResponse (Err reason) ->
            ( model.addTeamMemberMenu
                |> AddTeamMemberMenu.setState AddTeamMemberMenu.Error
                |> AppModel.asAddTeamMemberMenu model
            , Cmd.none
            )
