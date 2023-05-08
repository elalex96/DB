-- =============================================
-- Author:		Manuel Cruz
-- Create date: 28-07-17
-- Description:	
-- =============================================
CREATE PROCEDURE SP_FI_TempIdFactura 
	-- Add the parameters for the stored procedure here
@NombreFactura NVARCHAR(MAX)
AS
	declare @emisor varchar(15)
     BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
         SET NOCOUNT ON;

    -- Insert statements for procedure here
         DECLARE @Indice INT;
         SELECT @Indice = CHARINDEX('PDFS\',@NombreFactura);
         SELECT @NombreFactura = SUBSTRING(@NombreFactura,@Indice+5,LEN(@NombreFactura)-@Indice);

	 -- insert into FacLukoi  (NombrePDF) values (@NombreFactura)
         DECLARE @IdFatura INT;
	    --
         SELECT @IdFatura = t.IdFactura,@emisor = f.emisor
         FROM faclukoi t
		 inner join FI_Factura f on f.idfactura = t.idfactura
         WHERE NombrePDF = @NombreFactura
	    --
         SELECT @IdFatura AS IdFactura,@NombreFactura as Emisor;
     END;
--EXEC SP_FI_TempIdFactura 'C:\\Users\\Adinco33\\Documents\\Visual Studio 2015\\Projects\\ADINCO_Solution\\ADINCO_web\\PDFS\\1. 102014 F-OCTUBRE ROSA MARGARITA TRUEBA TOGNOLA.pdf'

