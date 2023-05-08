-- =============================================
-- Author:		Reyna Olvera
-- Create date: 19/08/2019
-- Description:extrae informaci�n de la tabla en_clasificacion
-- =============================================
CREATE PROCEDURE [dbo].[sp_EN_ExtraeClasificacion]--10061,3
    @idUsuario INT,
    @IdContrato INT
AS
BEGIN
    SET NOCOUNT ON;

	SELECT IdClasificacion,
	NombreClasificacion FROM En_Clasificacion where activo=1

	END