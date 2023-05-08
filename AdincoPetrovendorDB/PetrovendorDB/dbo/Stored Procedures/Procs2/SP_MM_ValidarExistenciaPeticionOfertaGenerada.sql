-- =============================================
-- Author:		<Abel Rivera>
-- Create date: <26 01 2018>
-- Description:	<Valida el estatus de la petición oferta>
-- =============================================
CREATE PROCEDURE SP_MM_ValidarExistenciaPeticionOfertaGenerada @IdSolPed      INT,
                                                               @IdUsuario     INT,
                                                               @IdContrato    INT,
                                                               @FechaRegistro DATETIME
AS
         BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
             SET NOCOUNT ON;
             SELECT(CASE SP.PeticionEnviada
                        WHEN(0)
                        THEN 'PETICION_NO_ENVIADA'
                        WHEN(1)
                        THEN 'PETICION_ENVIADA'
                        ELSE 'PETICION_NO_ENVIADA'
                    END) AS EstadoPeticionOferta
             FROM dbo.MM_SolicitudPedido SP
             WHERE SP.IdSolicitudPedido = @IdSolPed;
         END;
