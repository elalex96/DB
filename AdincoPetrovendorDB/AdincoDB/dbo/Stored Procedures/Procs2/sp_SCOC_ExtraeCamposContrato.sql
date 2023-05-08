/****** Object:  StoredProcedure [dbo].[sp_SCOC_ExtraeCamposContrato]    Script Date: 07/02/2019 12:25:19 p. m. ******/
-- =============================================
-- Author:		Reyna Olvera
-- Create date: 20181220
-- Description:Extrae campos del contrato
-- =============================================
CREATE PROCEDURE [dbo].[sp_SCOC_ExtraeCamposContrato] --10010,10061
    @idContrato INT,
    @idUsuario INT
AS
BEGIN
  SELECT C.CampoID as CampoID,
   C.NombreCampo AS NombreCampo,
   GasEntregadoEn,
PetroleoEntregadoEn,
CondensadoEntregadoEn
   FROM SCOC_CampoContrato CC
  JOIN dbo.SCOC_Campo  C ON C.CampoID=CC.CampoID
  WHERE CC.IdContrato=@idContrato AND CC.Bit_Activo=1-- AND c.Estatus=1
END;
