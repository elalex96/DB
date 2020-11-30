-- =============================================
-- Author:		<Pedro Acuña>
-- Create date: <08/03/2019>
-- Description:	<Store para validar que contenga un acta constitutiva para llenar el reporte de carta de contenido>
-- =============================================

CREATE PROCEDURE SP_ValidarActaConstitutiva @IdProveedor INT, @IdTipoRegimen INT
AS
	BEGIN
		IF ( @IdTipoRegimen = 2 )
			BEGIN
				SELECT	CURP AS IdActaConstitutiva
				  FROM	dbo.S_Proveedor
				 WHERE	IdProveedor = @IdProveedor
			END
		ELSE
			BEGIN
				SELECT	IdActaConstitutiva
				  FROM	dbo.DG_ActaConstitutiva
				 WHERE
						IdProveedor = @IdProveedor
						AND IsActivo = 1
			END
	END