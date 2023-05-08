-- =============================================
-- Author:		Alexander Gomez
-- Create date: 06/08/2018
-- Description:	Consulta los Servicios Generados filtrando por mes y contrato
-- =============================================
create PROCEDURE [dbo].[SG_ServiciosGeneradosMensualesContrato]
	-- Add the parameters for the stored procedure here
	@IdContrato INT,
	@Mes INT,
	@Anio INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT 
		SG.IdServicoGenerado,
		SG.Descripcion, 
		SG.FechaEmision, 
		SG.FechaRecepcion, 
		SG.IdContrato,
		US.Usuario
	FROM dbo.ServiciosGeneradosADINCO AS SG
	LEFT JOIN dbo.AP_Usuario AS US ON SG.IdUsuario = US.UsuarioID
	WHERE SG.FechaEmision >= CAST(CONCAT(@Mes,'/01/',@Anio) AS DATE) AND SG.FechaEmision <= EOMONTH(CAST(CONCAT(@Mes,'/01/',@Anio) AS DATE)) 
		AND SG.IdContrato = @IdContrato
		AND SG.Activo IS NULL
END