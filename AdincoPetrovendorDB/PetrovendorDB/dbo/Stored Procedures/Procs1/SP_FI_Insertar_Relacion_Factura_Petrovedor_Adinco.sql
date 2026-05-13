-- =============================================
-- Author:		Daniel  AC
-- Create date: 18-08-2017
-- Description:	Anexar relación de factura aprobada y enviada de petrovendor hacia adinco 
-- Update 28/02/2018 
-- Se agrego validación de que si ya existe un registro de esas facturas ya no se agregue otro registro
-- =============================================
CREATE PROCEDURE [dbo].[SP_FI_Insertar_Relacion_Factura_Petrovedor_Adinco] 
-- Add the parameters for the stored procedure here

@IdFacturaPetrovendor INT,
@UUID NVARCHAR(MAX)
 

AS
     BEGIN
         -- SET NOCOUNT ON added to prevent extra result sets from
         -- interfering with SELECT statements.
         SET NOCOUNT ON;
		 DECLARE @EXISTE INT
		 DECLARE @ID_FACTURA_ADINCO INT 
         -- Insert statements for procedure here
		   
		SET @EXISTE = (SELECT COUNT(IdFactura) FROM Adinco.dbo.FI_Factura WHERE UUID=@UUID)

		IF @EXISTE > 0 
		BEGIN
			 
			SELECT  @ID_FACTURA_ADINCO = IdFactura FROM Adinco.dbo.FI_Factura WHERE UUID=@UUID

			----VALIDAR QUE NO EXISTA UN REGISTRO YA DE ESA MISMA FACTURA TANTO DE ADINCO COMO PETROVENDOR, Y ACTUALIZAR EL ESTATUS O DETALLE 
			DECLARE @CONTADOR INT 

			SET @CONTADOR = (SELECT COUNT(FA.IdFacturaAdincoPetrovendor) 
			FROM Adinco.dbo.FI_FacturaAdincoPetrovendor AS FA
			WHERE FA.IdFacturaAdinco=@ID_FACTURA_ADINCO 
			AND FA.IdFacturaAdinco=@IdFacturaPetrovendor)

			IF @CONTADOR = 0 
			BEGIN
				INSERT INTO Adinco.dbo.FI_FacturaAdincoPetrovendor(IdFacturaPetrovendor, IdFacturaAdinco, FechaIntercambio, Activo)
				VALUES(@IdFacturaPetrovendor, @ID_FACTURA_ADINCO, GETDATE(), 1)
			END 
		END 
		ELSE
		BEGIN
			SET @ID_FACTURA_ADINCO = 0
		END


		 SELECT @ID_FACTURA_ADINCO

     END



	  

