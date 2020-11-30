-- =============================================
-- Author:		Manuel Cruz
-- Create date: 09-05-2018
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[SP_FI_GuardarComplementoReciboPago] 
	-- Add the parameters for the stored procedure here
@IdFactura       INT,
@Version         FLOAT,
@FechaDePago     DATETIME,
@MonedaP         NVARCHAR(50),
@FormaDePagoP    NVARCHAR(50),
@Monto           MONEY,
@NumOperacion    NVARCHAR(50),
@RfcEmisorCtaOrd NVARCHAR(50),
@NomBancoOrdExt  NVARCHAR(MAX),
@CtaOrdenante    NVARCHAR(50),
@RfcEmisorCtaBen NVARCHAR(50),
@CtaBeneficiario NVARCHAR(50),
@TipoDeCambio    FLOAT
AS
         BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
             SET NOCOUNT ON;
             DECLARE @Insertado INT;
    -- Insert statements for procedure here
             INSERT INTO [dbo].[FI_ComplementoDePago]
([IdFactura],
 [Version],
 [FechaDePago],
 [MonedaP],
 [FormaDePagoP],
 [Monto],
 [NumOperacion],
 [RfcEmisorCtaOrd],
 [NomBancoOrdExt],
 [CtaOrdenante],
 [RfcEmisorCtaBen],
 [CtaBeneficiario],
 [TipoDeCambio]
)
             VALUES
(@IdFactura,
 @Version,
 @FechaDePago,
 @MonedaP,
 @FormaDePagoP,
 @Monto,
 @NumOperacion,
 @RfcEmisorCtaOrd,
 @NomBancoOrdExt,
 @CtaOrdenante,
 @RfcEmisorCtaBen,
 @CtaBeneficiario,
 @TipoDeCambio
);
         END;
             SET @Insertado = @@IDENTITY;
             IF @@ERROR <> 0
                 SELECT 'false' AS msj,
                        0 AS IdComplementoDePago;
                 ELSE
             SELECT 'true' AS msj,
                    @Insertado AS IdComplementoDePago;
