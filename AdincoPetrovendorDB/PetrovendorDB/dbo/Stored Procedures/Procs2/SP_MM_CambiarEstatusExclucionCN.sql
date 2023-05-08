-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <09/12/2019>
-- Description:	<verificar y cambiar el estatus de la solicitud de exclicion cn>
--> Daniel AC /30-11-2022 --> Se agrega top 1 y orden desc para obtener la solicitud mas reciente y orden en la consultas
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_CambiarEstatusExclucionCN]
-- Add the parameters for the stored procedure here
@IdAceptacionPedido INT, 
@IdUsuario          INT
AS
    BEGIN
        -- SET NOCOUNT ON added to prevent extra result sets from
        -- interfering with SELECT statements.
        SET NOCOUNT ON;

        -- Insert statements for procedure here
        DECLARE @IdEstatus INT;
        DECLARE @IdAprobacionExlucionCN INT=
        (
            SELECT TOP 1 ISNULL(IdAprobacionExclucionCN, 0)
            FROM dbo.MM_Solicitud_ExclucionCN
            WHERE IdAceptacionPedido = @IdAceptacionPedido
			ORDER BY IdAprobacionExclucionCN DESC 
        );
        DECLARE @NoCarta BIT=
        (
            SELECT ISNULL(PedirCarta, 0)
            FROM dbo.RelacionCartaCNPedido
            WHERE IdAceptacionPedido = @IdAceptacionPedido
        );
        IF @IdAprobacionExlucionCN > 0
            BEGIN
                SET @IdEstatus =
                (
                    SELECT TOP 1 IdEstatus
                    FROM dbo.MM_Solicitud_ExclucionCN
                    WHERE IdAprobacionExclucionCN = @IdAprobacionExlucionCN					
                );

                --SI ESTA EN 0(NO CARTA) SIGNIFICA QUE APROBO LA SOLICITUD DE EXCLUCION
                IF @IdEstatus = 1
                   AND @NoCarta = 0
                    BEGIN
                        UPDATE dbo.MM_Solicitud_ExclucionCN
                          SET 
                              IdEstatus = 2, 
                              FechaEvaluacion = GETDATE(), 
                              UsuarioAprobador = @IdUsuario
                        WHERE IdAprobacionExclucionCN = @IdAprobacionExlucionCN;

                        SELECT 1, --0
                               AP.IdAceptacionPedido, --1
                               PS.IdPedido, --2
                               CONCAT(ISNULL(C.NumeroContrato, ''), ' - ', ISNULL(AC.NombreAreaContractual, '')) AS Contrato, --3
                               US.IdUsuario AS IdUsuarioAprobador, --4
                               US.Nombre AS NombreAprobador, --5
                               US.Correo AS CorreoAprobador, --6
                               PR.RazonSocial
                        FROM dbo.MM_AceptacionPedido AS AP (NOLOCK)
                             LEFT JOIN dbo.MM_Pedido AS P  (NOLOCK)
								ON AP.IdPedido = P.IdPedido 
                             LEFT JOIN dbo.MM_Pedidos AS PS  (NOLOCK)
								ON P.IdPedido = PS.IdIdentificador 
                                AND P.IdProveedorCompras = PS.IdProveedorCliente 
                             LEFT JOIN Adinco.dbo.CO_Contrato AS C  (NOLOCK)
								ON P.IdContrato = C.IdContrato 
                             LEFT JOIN Adinco.dbo.CO_AreaContractual AS AC  (NOLOCK)
								ON  C.IdAreaContractual =AC.IdAreaContractual
                             LEFT JOIN dbo.S_UsuarioProveedor AS USP  (NOLOCK)
								ON P.IdSubcontratista = USP.IdProveedor 
                             LEFT JOIN dbo.S_Usuario AS US  (NOLOCK)
								ON  USP.IdUsuario = US.IdUsuario
                             LEFT JOIN dbo.S_Proveedor AS PR  (NOLOCK)
								ON P.IdProveedorCompras = PR.IdProveedor 
                        WHERE AP.IdAceptacionPedido = @IdAceptacionPedido
                              AND US.Activo = 1
                              AND (US.IdTipoUsuario = 4
                                   OR US.IdTipoUsuario = 3) -->CTES VENTAS Y ADMINISTRADOR 
                        GROUP BY CONCAT(ISNULL(C.NumeroContrato, ''), ' - ', ISNULL(AC.NombreAreaContractual, '')), 
                                 AP.IdAceptacionPedido, 
                                 PS.IdPedido, 
                                 US.IdUsuario, 
                                 US.Nombre, 
                                 US.Correo, 
                                 PR.RazonSocial
                        UNION
                        SELECT 2, 
                               AP.IdAceptacionPedido, --0
                               PS.IdPedido, --1
                               CONCAT(ISNULL(C.NumeroContrato, ''), ' - ', ISNULL(AC.NombreAreaContractual, '')) AS Contrato, --2
                               USR.IdUsuario AS IdUsuarioRequisitor, --6
                               USR.Nombre AS NombreRequisitor, --7
                               USR.Correo AS CorreoRequisitor, --8
                               PR.RazonSocial
                        FROM dbo.MM_AceptacionPedido AS AP  (NOLOCK)
                             LEFT JOIN dbo.MM_Pedido AS P  (NOLOCK)
								ON AP.IdPedido = P.IdPedido 
                             LEFT JOIN dbo.MM_Pedidos AS PS  (NOLOCK)
								ON P.IdPedido = PS.IdIdentificador 
                                AND P.IdProveedorCompras = PS.IdProveedorCliente 
                             LEFT JOIN Adinco.dbo.CO_Contrato AS C  (NOLOCK)
								ON P.IdContrato = C.IdContrato 
                             LEFT JOIN Adinco.dbo.CO_AreaContractual AS AC  (NOLOCK)
								ON C.IdAreaContractual = AC.IdAreaContractual 
                             LEFT JOIN dbo.MM_SolicitudPedido AS SP  (NOLOCK)
								ON  P.IdSolicitudPedido = SP.IdSolicitudPedido
                             LEFT JOIN dbo.S_Usuario AS USR  (NOLOCK)
								ON SP.IdUsuarioSolicitante = USR.IdUsuario 
                             LEFT JOIN dbo.S_Proveedor AS PR  (NOLOCK)
								ON P.IdSubcontratista = PR.IdProveedor 
                        WHERE AP.IdAceptacionPedido = @IdAceptacionPedido
                        GROUP BY CONCAT(ISNULL(C.NumeroContrato, ''), ' - ', ISNULL(AC.NombreAreaContractual, '')), 
                                 AP.IdAceptacionPedido, 
                                 PS.IdPedido, 
                                 USR.IdUsuario, 
                                 USR.Nombre, 
                                 USR.Correo, 
                                 PR.RazonSocial;
                END;

                --SI ESTA EN 1(SI CARTA) SIGNIFICA QUE RECHAZO LA SOLICITUD DE EXCLUCION
                IF @IdEstatus = 1
                   AND @NoCarta = 1
                    BEGIN
                        UPDATE dbo.MM_Solicitud_ExclucionCN
                          SET 
                              IdEstatus = 3, 
                              FechaEvaluacion = GETDATE(), 
                              UsuarioAprobador = @IdUsuario
                        WHERE IdAprobacionExclucionCN = @IdAprobacionExlucionCN;

                        SELECT 3, 
                               AP.IdAceptacionPedido, --0
                               PS.IdPedido, --1
                               CONCAT(ISNULL(C.NumeroContrato, ''), ' - ', ISNULL(AC.NombreAreaContractual, '')) AS Contrato, --2
                               USR.IdUsuario AS IdUsuarioRequisitor, --6
                               USR.Nombre AS NombreRequisitor, --7
                               USR.Correo AS CorreoRequisitor, --8
                               PR.RazonSocial
                        FROM dbo.MM_AceptacionPedido AS AP  (NOLOCK)
                             LEFT JOIN dbo.MM_Pedido AS P  (NOLOCK)
								ON  AP.IdPedido = P.IdPedido 
                             LEFT JOIN dbo.MM_Pedidos AS PS  (NOLOCK)
								ON P.IdPedido = PS.IdIdentificador 
                                   AND P.IdProveedorCompras = PS.IdProveedorCliente 
                             LEFT JOIN Adinco.dbo.CO_Contrato AS C  (NOLOCK)
								ON P.IdContrato = C.IdContrato 
                             LEFT JOIN Adinco.dbo.CO_AreaContractual AS AC  (NOLOCK)
								ON C.IdAreaContractual = AC.IdAreaContractual 
                             LEFT JOIN dbo.MM_SolicitudPedido AS SP  (NOLOCK)
								ON P.IdSolicitudPedido = SP.IdSolicitudPedido 
                             LEFT JOIN dbo.S_Usuario AS USR  (NOLOCK)
								ON SP.IdUsuarioSolicitante = USR.IdUsuario
                             LEFT JOIN dbo.S_Proveedor AS PR  (NOLOCK)
								ON P.IdSubcontratista = PR.IdProveedor
                        WHERE AP.IdAceptacionPedido = @IdAceptacionPedido
                        GROUP BY CONCAT(ISNULL(C.NumeroContrato, ''), ' - ', ISNULL(AC.NombreAreaContractual, '')), 
                                 AP.IdAceptacionPedido, 
                                 PS.IdPedido, 
                                 USR.IdUsuario, 
                                 USR.Nombre, 
                                 USR.Correo, 
                                 PR.RazonSocial;
                END;
                IF @IdEstatus = 2
                   AND @NoCarta = 1
                    BEGIN
                        SELECT 2, 
                               AP.IdAceptacionPedido, --0
                               PS.IdPedido, --1
                               CONCAT(ISNULL(C.NumeroContrato, ''), ' - ', ISNULL(AC.NombreAreaContractual, '')) AS Contrato, --2
                               USR.IdUsuario AS IdUsuarioRequisitor, --6
                               USR.Nombre AS NombreRequisitor, --7
                               USR.Correo AS CorreoRequisitor, --8
                               PR.RazonSocial
                        FROM dbo.MM_AceptacionPedido AS AP  (NOLOCK)
                             LEFT JOIN dbo.MM_Pedido AS P  (NOLOCK)
								ON AP.IdPedido = P.IdPedido 
                             LEFT JOIN dbo.MM_Pedidos AS PS  (NOLOCK)
								ON  P.IdPedido = PS.IdIdentificador
                                AND P.IdProveedorCompras = PS.IdProveedorCliente
                             LEFT JOIN Adinco.dbo.CO_Contrato AS C  (NOLOCK)
								ON P.IdContrato = C.IdContrato 
                             LEFT JOIN Adinco.dbo.CO_AreaContractual AS AC  (NOLOCK)
								ON  C.IdAreaContractual = AC.IdAreaContractual
                             LEFT JOIN dbo.MM_SolicitudPedido AS SP  (NOLOCK)
								ON P.IdSolicitudPedido = SP.IdSolicitudPedido 
                             LEFT JOIN dbo.S_Usuario AS USR  (NOLOCK)
								ON SP.IdUsuarioSolicitante = USR.IdUsuario 
                             LEFT JOIN dbo.S_Proveedor AS PR  (NOLOCK)
								ON P.IdSubcontratista = PR.IdProveedor 
                        WHERE AP.IdAceptacionPedido = @IdAceptacionPedido
                        GROUP BY CONCAT(ISNULL(C.NumeroContrato, ''), ' - ', ISNULL(AC.NombreAreaContractual, '')), 
                                 AP.IdAceptacionPedido, 
                                 PS.IdPedido, 
                                 USR.IdUsuario, 
                                 USR.Nombre, 
                                 USR.Correo, 
                                 PR.RazonSocial;
                END;
                IF @IdEstatus = 3
                   AND @NoCarta = 1
                    BEGIN
                        SELECT 3, 
                               AP.IdAceptacionPedido, --0
                               PS.IdPedido, --1
                               CONCAT(ISNULL(C.NumeroContrato, ''), ' - ', ISNULL(AC.NombreAreaContractual, '')) AS Contrato, --2
                               USR.IdUsuario AS IdUsuarioRequisitor, --6
                               USR.Nombre AS NombreRequisitor, --7
                               USR.Correo AS CorreoRequisitor, --8
                               PR.RazonSocial
                        FROM dbo.MM_AceptacionPedido AS AP  (NOLOCK)
                             LEFT JOIN dbo.MM_Pedido AS P  (NOLOCK)
								ON  AP.IdPedido = P.IdPedido
                             LEFT JOIN dbo.MM_Pedidos AS PS  (NOLOCK)
								ON  P.IdPedido = PS.IdIdentificador
                                AND P.IdProveedorCompras = PS.IdProveedorCliente
                             LEFT JOIN Adinco.dbo.CO_Contrato AS C  (NOLOCK)
								ON P.IdContrato = C.IdContrato 
                             LEFT JOIN Adinco.dbo.CO_AreaContractual AS AC  (NOLOCK)
								ON C.IdAreaContractual = AC.IdAreaContractual 
                             LEFT JOIN dbo.MM_SolicitudPedido AS SP  (NOLOCK)
								ON  P.IdSolicitudPedido = SP.IdSolicitudPedido 
                             LEFT JOIN dbo.S_Usuario AS USR  (NOLOCK)
								ON  SP.IdUsuarioSolicitante = USR.IdUsuario 
                             LEFT JOIN dbo.S_Proveedor AS PR  (NOLOCK)
								ON P.IdSubcontratista = PR.IdProveedor 
                        WHERE AP.IdAceptacionPedido = @IdAceptacionPedido
                        GROUP BY CONCAT(ISNULL(C.NumeroContrato, ''), ' - ', ISNULL(AC.NombreAreaContractual, '')), 
                                 AP.IdAceptacionPedido, 
                                 PS.IdPedido, 
                                 USR.IdUsuario, 
                                 USR.Nombre, 
                                 USR.Correo, 
                                 PR.RazonSocial;
                END;
        END;
    END;