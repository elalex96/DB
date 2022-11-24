-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <09/12/2019>
-- Description:	<verificar y cambiar el estatus de la solicitud de exclicion cn>
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_ValidacionDEACartaCNExclucion] --10992,0
-- Add the parameters for the stored procedure here
@IdAceptacionPedido INT, 
@IdUsuario          INT
AS
    BEGIN
        -- SET NOCOUNT ON added to prevent extra result sets from
        -- interfering with SELECT statements.
        SET NOCOUNT ON;

        -- Insert statements for procedure here
		DECLARE @IDCONTRATO INT = (SELECT TOP 1 IdContrato 
									FROM MM_Pedido AS P
									JOIN MM_AceptacionPedido AS AP 
										ON AP.IdPedido = P.IdPedido
									WHERE AP.IdAceptacionPedido = @IdAceptacionPedido);

		--EN CASO DE SER WD ADMIN AGREGARLO COMO PedirCarta = 1
		--IF @IDCONTRATO = 3
		IF @IDCONTRATO = 10145--CNH-WD ADMIN
		BEGIN 

						SELECT 1, --0
                               AP.IdAceptacionPedido, --1
                               PS.IdPedido, --2
                               CONCAT(ISNULL(C.NumeroContrato, ''), ' - ', ISNULL(AC.NombreAreaContractual, '')) AS Contrato, --3
                               US.IdUsuario AS IdUsuarioAprobador, --4
                               US.Nombre AS NombreAprobador, --5
                               US.Correo AS CorreoAprobador, --6
                               PR.RazonSocial
                        FROM dbo.MM_AceptacionPedido AS AP
                             LEFT JOIN dbo.MM_Pedido AS P ON P.IdPedido = AP.IdPedido
                             LEFT JOIN dbo.MM_Pedidos AS PS ON PS.IdIdentificador = P.IdPedido
                                                               AND PS.IdProveedorCliente = P.IdProveedorCompras
                             LEFT JOIN Adinco.dbo.CO_Contrato AS C ON C.IdContrato = P.IdContrato
                             LEFT JOIN Adinco.dbo.CO_AreaContractual AS AC ON AC.IdAreaContractual = C.IdAreaContractual
                             LEFT JOIN dbo.S_UsuarioProveedor AS USP ON USP.IdProveedor = P.IdSubcontratista
                             LEFT JOIN dbo.S_Usuario AS US ON US.IdUsuario = USP.IdUsuario
                             LEFT JOIN dbo.S_Proveedor AS PR ON PR.IdProveedor = P.IdProveedorCompras
                        WHERE AP.IdAceptacionPedido = @IdAceptacionPedido
                              AND US.Activo = 1
                              AND (US.IdTipoUsuario = 4
                                   OR US.IdTipoUsuario = 3)
                        GROUP BY CONCAT(ISNULL(C.NumeroContrato, ''), ' - ', ISNULL(AC.NombreAreaContractual, '')), 
                                 AP.IdAceptacionPedido, 
                                 PS.IdPedido, 
                                 US.IdUsuario, 
                                 US.Nombre, 
                                 US.Correo, 
                                 PR.RazonSocial
		
		END
                        
END;