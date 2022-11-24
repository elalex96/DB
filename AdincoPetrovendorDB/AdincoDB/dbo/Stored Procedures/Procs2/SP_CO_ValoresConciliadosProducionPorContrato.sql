CREATE PROCEDURE [dbo].[SP_CO_ValoresConciliadosProducionPorContrato]
	@IdContrato INT = 0,
	@IdUsuario INT = 0
AS
BEGIN		
	SET LANGUAGE spanish;
	SELECT 
		VCP.IdValoresConciliadosProducion,
		PE.Nombre AS PuntoEntrega,
		VCP.PuntoEntregaID,
		CONCAT(DATENAME(MONTH, VCP.Mes), ' ', YEAR(VCP.Mes)) AS Mes,
		CAST(VCP.Mes AS DATE) AS IdFecha,
		VCP.Aceite,
		VCP.Gas,
		VCP.Agua,
		C.Nombre AS CreadoPor,
		VCP.CreadoEl,
		M.Nombre AS ModificadoPor,
		VCP.ModificadoEl
	FROM [CO_ValoresConciliadosProducion] VCP
	JOIN [dbo].[CO_PuntosdeEntrega] PE ON VCP.IdContrato = @IdContrato AND 
										  VCP.Activo = 1 AND 
								          VCP.PuntoEntregaID = PE.PuntoEntregaID
	JOIN [dbo].[AP_Usuario] C ON VCP.CreadoPor = C.UsuarioID
	LEFT JOIN [dbo].[AP_Usuario] M ON VCP.ModificadoPor = M.UsuarioID
END