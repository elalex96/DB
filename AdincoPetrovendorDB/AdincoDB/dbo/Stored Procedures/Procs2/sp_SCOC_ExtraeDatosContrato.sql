-- =============================================
-- Author:		Reyna Olvera
-- Create date: 20181220
-- Description:Extrae Datos del contrato
-- =============================================
CREATE PROCEDURE [dbo].[sp_SCOC_ExtraeDatosContrato] --10010,10061
    @idContrato INT,
    @idUsuario INT
AS
BEGIN
    SELECT IdContrato,
           SubdireccionProduccion,
           ActivoIntegral,
           PetroleoEntregadoA,
          -- PetroleoEntregadoEn,
           PetroleoTransporte,
           GasEntregadoA,
          -- GasEntregadoEn,
           GasTransporte,
           CondensadoEntregadoA,
           --CondensadoEntregadoEn,
           CondensadoTransporte,
           InicialesSocio,
           DescripcionSocio,
           PuntosLecturaCroma,
           AplicaFactorCompresibilidad,
		   Balance,
		   Condensable,
		   BitPetroleo,
		   BitGas,
		   DireccionPetroleoEntregadoA,
		   DireccionGasEntregadoA,
		   DireccionCondensadoEntregadoA,
           CreadoPor,
           CreadoEn,
           ModificadoPor,
           ModificadoEn
 FROM dbo.SCOC_Contrato
    WHERE IdContrato = @idContrato;
END;
