-- =============================================
-- Author:		Miguel Gomez
-- Create date: 2017-01-01
-- Description: Ineerta un nuevo registro de producción
-- =============================================
CREATE PROCEDURE sp_PR_InsertaVolumenMensualProduccion 
	-- Add the parameters for the stored procedure here
@IdContrato	int ,
@MesReporte	date ,
@VolumenPetroleoPuntoMedicion	float ,
@GradosAPI	float ,
@ContenidoAzufre	float ,
@VolumenPetroleoAutoconsumo	float ,
@MetanoC1	float ,
@EtanoC2	float ,
@PropanoC3	float ,
@ButanoC4	float ,
@MetanoC1Autoconsumo	float ,
@EtanoC2Autoconsumo	float ,
@PropanoC3Autoconsumo	float ,
@ButanoC4Autoconsumo	float ,
@VolumenCondensadoPuntoMedicion	float ,
@VolumenCondensadoAutoconsumo	float 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @InsertedRecord INT;
    -- Insert statements for procedure here
	INSERT INTO dbo.PR_VolumenMensualProduccionPetroleo
(IdContrato,
 MesReporte,
 VolumenPetroleoPuntoMedicion,
 GradosAPI,
 ContenidoAzufre,
 VolumenPetroleoAutoconsumo,
 MetanoC1,
 EtanoC2,
 PropanoC3,
 ButanoC4,
 MetanoC1Autoconsumo,
 EtanoC2Autoconsumo,
 PropanoC3Autoconsumo,
 ButanoC4Autoconsumo,
 VolumenCondensadoPuntoMedicion,
 VolumenCondensadoAutoconsumo
)
VALUES
(@IdContrato,
 @MesReporte,
 @VolumenPetroleoPuntoMedicion,
 @GradosAPI,
 @ContenidoAzufre,
 @VolumenPetroleoAutoconsumo,
 @MetanoC1,
 @EtanoC2,
 @PropanoC3,
 @ButanoC4,
 @MetanoC1Autoconsumo,
 @EtanoC2Autoconsumo,
 @PropanoC3Autoconsumo,
 @ButanoC4Autoconsumo,
 @VolumenCondensadoPuntoMedicion,
 @VolumenCondensadoAutoconsumo
)
END

SELECT @InsertedRecord AS INSERTADO,
       CONCAT('Los volumenes mensuales de producción se han guardado exitosamente con el número de transacción (TR) ', @InsertedRecord) AS MSG

