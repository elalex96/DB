-- =============================================
-- Author:		Alexander Gomez
-- Create date: 06/08/2018
-- Description:	Consulta el encabezado del reporte de servicios generados de adinco
-- =============================================
create PROCEDURE SG_ServiciosGeneradosCabeceraADINCO 
	-- Add the parameters for the stored procedure here
	@IdContrato INT,
	@IdUsuario INT
	--@Anio INT,
	--@Mes INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
    DECLARE @CORREO NVARCHAR(MAX) =	(SELECT Usuario FROM dbo.AP_Usuario WHERE UsuarioID = @IdUsuario)

	--DECLARE @FECHAINICIO DATETIME = (CAST(CONCAT(@Mes,'/01/',@Anio) AS DATE))
	--DECLARE @FECHAFIN DATETIME = (EOMONTH(CAST(CONCAT(@Mes,'/01/',@Anio) AS DATE)))

	SELECT 
		--CAST(@FECHAINICIO AS NVARCHAR(50)) AS FechaInicio,
		--CAST(@FECHAFIN AS NVARCHAR(50)) AS FechaFin,
		CO.NumeroContrato, 
		CA.NombreContratista,
		CA.RazonSocial AS SubContratista, 
		CA.RFC, 
		CA.Calle + ',' + CA.Numero + ',' + CA.CodigoPostal + ',' + CA.Colonia + ',' + CA.Entidad + ',' + CA.Municipio + ',' + CA.Pais AS Domicilio,
		@CORREO AS Correo
	FROM dbo.CO_Contrato AS CO
	LEFT JOIN dbo.CO_Contratista AS CA ON CA.IdContratista = CO.IdContratista
	WHERE CO.IdContrato = @IdContrato

END