CREATE PROCEDURE [dbo].[SP_Combo_Cuentacontable] 
@IdContrato int
AS
BEGIN
    SELECT Id,
          Numero + ' - ' + Descripcion as Descripcion
    FROM dbo.DG_CuentaContable 
	where IdContrato = @IdContrato
	AND ISNULL(Activo,0) = 1;

END