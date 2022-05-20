
CREATE  PROCEDURE [dbo].[EPT_ObtenImportaLayout]
	@IdContrato INT,
	@IdUsuario INT
AS
BEGIN
    SET NOCOUNT ON;
	 SET LANGUAGE spanish;
	SELECT 
	ILD.Id,
	IL.ArchivoImportado,
	IL.UsuarioId,
	IL.ContratoId,
	IL.CreadoEn,
	ILD.Contrato,
	ILD.IdentificadorDocumento,
	ILD.NombreDocumento,
	ILD.Mes,
	ILD.Anio,
	U.Nombre AS CreadoPorUsuario,
	IL.CreadoEn
	FROM 
		EPT_ImportacionLayout IL
	JOIN
		EPT_ImportacionLayoutDetalle ILD
		ON	IL.Id	=	ILD.ImportacionLayoutId
	LEFT	JOIN
		AP_Usuario U
		ON IL.UsuarioId	=	U.UsuarioID
	WHERE 
		IL.ContratoId = @IdContrato
	 ORDER BY IL.CreadoEn DESC;
END;
