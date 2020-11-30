CREATE PROCEDURE [dbo].[SP_TC_ConsultarComboTyC]
	@IdProveedor INT
AS
BEGIN
	
	SELECT IdTerminosYCondiciones, Nombre from dbo.TC_TerminosYCondicionesDocV2
	WHERE IdProveedor = @IdProveedor AND IsActivo = 1

END