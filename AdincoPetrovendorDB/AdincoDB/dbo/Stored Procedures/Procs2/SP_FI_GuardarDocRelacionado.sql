-- =============================================
-- Author:		Manuel Cruz
-- Create date: 09-05-2018
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[SP_FI_GuardarDocRelacionado] 
	-- Add the parameters for the stored procedure here
@IdComplementoDePago INT,
@IdDocumento         NVARCHAR(MAX),
@Serie               NVARCHAR(50),
@Folio               NVARCHAR(50),
@MetodoDePagoDR      NVARCHAR(50),
@MonedaDR            NVARCHAR(50),
@ImpSaldoAnt         MONEY,
@ImpSaldoInsoluto    MONEY,
@ImpPagado           MONEY,
@NumParcialidad      INT,
@TipoDeCambioDR      FLOAT
AS
         BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
             SET NOCOUNT ON;

    -- Insert statements for procedure here
             INSERT INTO [dbo].[FI_CPDocRelacionado]
([IdComplementoDePago],
 [IdDocumento],
 [Serie],
 [Folio],
 [MetodoDePagoDR],
 [MonedaDR],
 [ImpSaldoAnt],
 [ImpSaldoInsoluto],
 [ImpPagado],
 [NumParcialidad],
 [TipoDeCambioDR]
)
             VALUES
(@IdComplementoDePago,
 @IdDocumento,
 @Serie,
 @Folio,
 @MetodoDePagoDR,
 @MonedaDR,
 @ImpSaldoAnt,
 @ImpSaldoInsoluto,
 @ImpPagado,
 @NumParcialidad,
 @TipoDeCambioDR
);
         END;
             IF @@ERROR <> 0
                 SELECT 'false' AS msj;
                 ELSE
             SELECT 'true' AS msj;
