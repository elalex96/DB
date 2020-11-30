-- =============================================
-- Author:		José Miguel Gómez
-- Create date: 2 de Agosto de 2010
-- Description:	Procedimiento para obtener el numero de folio siguiente, dependiendo del almacen y el tipo de movimiento a realizar
-- =============================================
CREATE PROCEDURE [dbo].[FolioMovimiento]
	-- Add the parameters for the stored procedure here
	@almacen as nvarchar(max),
	@tipomovimiento int
	AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	declare 
		@foliomayor as int,
		@clavemovimiento as nvarchar(10)
    -- Insert statements for procedure here
	-- Busca el folio mayor de acuerdo al almacen y al tipo de movimiento 
	SELECT @foliomayor = MAX (no_folio) from admin_movimientos_almacn where clave_almacen =@almacen and tipomovimiento = @tipomovimiento 
	
	-- Inserta registro temporal con el fin de marcar el numero del folio
	INSERT INTO [DS].[dbo].[admin_movimientos_almacn]
           ([no_folio]
           ,[comentarios]
           ,[clave_almacen]
           ,[tipomovimiento]  )
    VALUES
           (@foliomayor+1
           ,'Folio en proceso de guardado'
           ,@almacen
           ,@tipomovimiento)
           
    SELECT   @clavemovimiento  =
      CASE @tipomovimiento
         WHEN 1 THEN  'R'
         WHEN 2 THEN  'E'
         WHEN 3 THEN  'RI'
         ELSE  'ND'
      END
    
	--Selecciona el numero de folio corresponediente
	SELECT    UPPER( @almacen ) + '-0' + RTRIM(@foliomayor+1)+ '-' + @clavemovimiento as folio , RTRIM(@foliomayor+1) as no_folio
END
