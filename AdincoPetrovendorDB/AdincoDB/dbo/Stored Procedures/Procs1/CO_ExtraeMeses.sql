-- =============================================
-- Author:		Reyna Olvera
-- Create date: 13/02/2018
-- Description:	ExtraeMese
-- =============================================
CREATE PROCEDURE [dbo].[CO_ExtraeMeses]
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
		Select  Distinct (NombreMes),mes from ap_calendario 
		where anio=2018
		order by mes asc
		
END

