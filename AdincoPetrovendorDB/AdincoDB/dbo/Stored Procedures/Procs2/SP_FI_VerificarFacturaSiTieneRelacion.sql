-- =============================================
-- Author:		Manuel CD
-- Create date: 26-02-2018
-- Description:	
-- =============================================
CREATE PROCEDURE SP_FI_VerificarFacturaSiTieneRelacion 
	-- Add the parameters for the stored procedure here
@IdFactura  INT,
@IdUsuario  INT,
@IdContrato INT
AS
         BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
             SET NOCOUNT ON;
             DECLARE @IdTransfer INT;
             DECLARE @IdRegistro INT;
    -- Insert statements for procedure here
             IF EXISTS
(
    SELECT *
    FROM dbo.FI_TransferFactura
    WHERE IdFactura = @IdFactura
)
                OR EXISTS
(
    SELECT *
    FROM dbo.CO_Registro
    WHERE IdFactura = @IdFactura
)
                /*OR EXISTS
(
    SELECT *
    FROM dbo.FI_Documento
    WHERE IdFactura = @IdFactura
)*/
                 SELECT 1 AS Relacion;
                 ELSE
             SELECT 0 AS Relacion;
         END;