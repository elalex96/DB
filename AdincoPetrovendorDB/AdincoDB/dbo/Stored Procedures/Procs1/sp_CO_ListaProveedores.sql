-- =============================================
-- Author:		Manuel Cruz
-- Create date: 8-06-17
-- Description:	
-- =============================================
CREATE PROCEDURE sp_CO_ListaProveedores 
	-- Add the parameters for the stored procedure here
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
SELECT IdSubcontratista,
       RFC,      
	  concat (RazonSocial, '  -  ' , RFC) as Descripcion

FROM PV_Subcontratista 
where rtrim (razonsocial) <> '' order by razonSocial ;

END