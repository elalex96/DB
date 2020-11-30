
-- =============================================
-- Author:		Luis De la Cruz
-- Create date: 14/09/17
-- Description:	Nombre y ubicacion para area contractual
-- =============================================
CREATE PROCEDURE [dbo].[Sp_CO_AreaNombreContractual]
	-- Add the parameters for the stored procedure here
	@idArea int
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
Select Top 1 lat,lng,NombreAreaContractual FROM CO_Coordenadas CO_Co inner join co_AreaContractual CO_A on CO_Co.idAreaContractual=CO_A.idAreaContractual where CO_co.IdAreaContractual =@idArea;
END

