-- =============================================
-- Author:		Pedro, Acuña
-- Create date: 31/01/2018
-- Description:	Consultar los documentos registrados para mostrarlos en el grid de oferta de adjudicacion directa (Justificacion)
-- =============================================
CREATE PROCEDURE SP_AD_ObtenerDocumento
    @Id INT,
    @IdContrato INT,
    @Idusuario INT,
    @FchRegistro DATETIME
AS
BEGIN
	SELECT Documento FROM dbo.AD_Documento WHERE Id = @Id
END	