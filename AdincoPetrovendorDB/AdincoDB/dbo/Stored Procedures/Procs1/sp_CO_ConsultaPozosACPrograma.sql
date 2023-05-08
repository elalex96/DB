-- =============================================
-- Author:		Miguel Gomez
-- Create date: 30-12-2016
-- Description:	Consulta el listado de instalaciones filtrado por pozo de una determinada area contractual
-- =============================================
CREATE PROCEDURE [sp_CO_ConsultaPozosACPrograma] 
	-- Add the parameters for the stored procedure here
	@IdAreaContractual int = 0, 
	@p2 int = 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT I.IdInstalacion,  I.NombreInstalacion AS NombreParaMostrar, '[' + CAST( i.IdInstalacion AS nvarchar(MAX)) +'] ' +   I.NombreInstalacion AS NombreParaMostrarId from CO_Instalacion I 
	JOIN CO_ActividadCIEP A ON I.IdActividad = A.IdActividad
	WHERE I.IdAreaContractual = @IdAreaContractual
	and A.ID_CATACTIV = 5
	ORDER BY NombreParaMostrar 


END
