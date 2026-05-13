-- =============================================
-- Author:		Manuel CD
-- Create date: 24-10-17
-- Description:	
-- =============================================
CREATE PROCEDURE SP_GE_NombreExcel --1,'2017-10-21',3
	-- Add the parameters for the stored procedure here
	@IdActividad INT,
	@Fecha DATE,
	@IdContrato INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	         DECLARE @Etiqueta1 NVARCHAR(50);
		    DECLARE @Etiqueta2 NVARCHAR(50);
         SELECT @Etiqueta1 = 'GEAdministracion', @Etiqueta2 = 'T_GEADMON'
         WHERE @IdActividad = 1;
         SELECT @Etiqueta1 = 'GEDuctos', @Etiqueta2 = 'T_GEDUCTOS'
         WHERE @IdActividad = 2;
         SELECT @Etiqueta1 = 'GEEstudios', @Etiqueta2 = 'T_GEESTUD'
         WHERE @IdActividad = 3;
         SELECT @Etiqueta1 = 'GEInstalaciones', @Etiqueta2 = 'T_GEINST'
         WHERE @IdActividad = 4;
         SELECT @Etiqueta1 = 'GEPozos', @Etiqueta2 = 'T_GEPOZOS'
         WHERE @IdActividad = 5;

    -- Insert statements for procedure here
	SELECT CONCAT(NumeroContrato,@Etiqueta1,convert(varchar(8),cast(@Fecha as date),112)) AS NombreExcel,@Etiqueta2 AS NombreHoja
	FROM CO_Contrato
	WHERE IdContrato = @IdContrato
END

