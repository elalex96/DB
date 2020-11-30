-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE SP_GR_ConsultarGuia
@IdGuia INT,

@Contrato INT = NULL,
@Usuario INT = NULL ,
@FechaRegistro DATETIME = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT NombreGuia,Archivo FROM dbo.GuiasRapidas WHERE IdGuiaRapida = @IdGuia

END
