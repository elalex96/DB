CREATE TABLE [dbo].[PV_Subcontratista] (
    [IdSubcontratista]    INT           IDENTITY (10000, 1) NOT NULL,
    [RFC]                 VARCHAR (30)  NULL,
    [RazonSocial]         VARCHAR (MAX) NULL,
    [RepresentanteLegal]  VARCHAR (MAX) NULL,
    [DiasCreditoID]       INT           NULL,
    [Giro]                VARCHAR (MAX) NULL,
    [PatronalIMSS]        VARCHAR (MAX) NULL,
    [TipoPersonaFiscalID] INT           NULL,
    [NacionalidadID]      INT           NULL,
    [ClasificacionID]     INT           NULL,
    [Capital]             VARCHAR (50)  NULL,
    [IdStatusValidacion]  INT           NULL,
    [MotivoRechazo]       VARCHAR (MAX) NULL,
    [NombreComercial]     VARCHAR (MAX) NULL,
    [CURP]                VARCHAR (50)  NULL,
    [FormaPagoID]         INT           NULL,
    [GrupoCuentasID]      INT           NULL,
    [UsuarioID]           INT           NULL,
    CONSTRAINT [PK_Cat_Empresa] PRIMARY KEY CLUSTERED ([IdSubcontratista] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);


GO
CREATE NONCLUSTERED INDEX [IX_PV_Subcontratista]
    ON [dbo].[PV_Subcontratista]([RFC] ASC)
    INCLUDE([IdSubcontratista]) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON);


GO
CREATE TRIGGER dbo.PV_Subcontratista_UTRG ON PV_Subcontratista FOR UPDATE NOT FOR REPLICATION
AS
BEGIN

IF @@ROWCOUNT = 0
    GOTO FIN

SET NOCOUNT ON

-- VALIDAMOS SI YA EXISTE EL PROVEEDOR EN LA TABLA DE ADINCO YA SEA CON EL RFC O CON EL ID
IF 0 = (SELECT  COUNT(1)
	   FROM	   ADINCO_DESARROLLO.dbo.PV_Subcontratista ADINCO
	   JOIN	   INSERTED	I
		  ON  ADINCO.RFC	COLLATE Modern_Spanish_CI_AS =   I.RFC
	   )
	   AND
    0 = (SELECT  COUNT(1)
	   FROM	   ADINCO_DESARROLLO.dbo.PV_Subcontratista ADINCO
	   JOIN	   INSERTED	I
		  ON  ADINCO.IdPetroVendor	=   I.IdSubcontratista
	   )
BEGIN
-- SE INSERTA EL PROVEEDOR EN ADINCO
	INSERT INTO ADINCO_DESARROLLO.dbo.PV_Subcontratista
	(
	   RFC,
	   RazonSocial,
	   RepresentanteLegal,
	   DiasCreditoID,
	   Giro,
	   PatronalIMSS,
	   TipoPersonaFiscalID,
	   NacionalidadID,
	   ClasificacionID,
	   Capital,
	   IdStatusValidacion,
	   MotivoRechazo,
	   NombreComercial,
	   CURP,
	   FormaPagoID,
	   GrupoCuentasID,
	   UsuarioID,
	   IdPetroVendor
	   --RegimenCapital
	   --FechaConstitucion
	   --FechaOperacion
	   --SituacionContribuyente
	   --FechaCambioSituacion
	   --Pais
	   --Entidad
	   --Municipio
	   --Colonia
	   --TipoVialidad
	   --NombreVialidad
	   --NumExterior
	   --NumInterior
	   --CodigoPostal
	   --IsEliminado
	   --ImagenSrc
	   --Relacionada
	)
	SELECT
	   RFC,
	   RazonSocial,
	   RepresentanteLegal,
	   DiasCreditoID,
	   Giro,
	   PatronalIMSS,
	   TipoPersonaFiscalID,
	   NacionalidadID,
	   ClasificacionID,
	   Capital,
	   IdStatusValidacion,
	   MotivoRechazo,
	   NombreComercial,
	   CURP,
	   FormaPagoID,
	   GrupoCuentasID,
	   UsuarioID,
	   IdSubcontratista
	FROM
		INSERTED
		
END
ELSE
BEGIN
    -- SI YA EXISTE EL PROVEEDOR, SOLO LE ACTUALIZAMOS LA INFORMACIÓN
    -- BUSCAMOS POR ID
    UPDATE  ADINCO
	   SET IdPetroVendor   =	  I.IdSubcontratista,
	   RazonSocial		   =	  I.RazonSocial,
	   RepresentanteLegal  =	  I.RepresentanteLegal,
	   DiasCreditoID	   =	  I.DiasCreditoID,
	   Giro			   =	  I.Giro,
	   PatronalIMSS	   =	  I.PatronalIMSS,
	   TipoPersonaFiscalID =	  I.TipoPersonaFiscalID,
	   NacionalidadID	   =	  I.NacionalidadID,
	   ClasificacionID	   =	  I.ClasificacionID,
	   Capital		   =	  I.Capital,
	   IdStatusValidacion  =	  I.IdStatusValidacion,
	   MotivoRechazo	   =	  I.MotivoRechazo,
	   NombreComercial	   =	  I.NombreComercial,
	   CURP			   =	  I.CURP,
	   FormaPagoID		   =	  I.FormaPagoID,
	   GrupoCuentasID	   =	  I.GrupoCuentasID
    FROM
    	   ADINCO_DESARROLLO.dbo.PV_Subcontratista ADINCO
    JOIN
    	   INSERTED	I
	   ON  ADINCO.IdPetroVendor	=   I.IdSubcontratista
END

FIN:

END

GO
CREATE TRIGGER dbo.PV_Subcontratista_ITRG ON PV_Subcontratista FOR INSERT NOT FOR REPLICATION
AS
BEGIN

IF @@ROWCOUNT = 0
    GOTO FIN

SET NOCOUNT ON

-- VALIDAMOS SI YA EXISTE EL PROVEEDOR EN LA TABLA DE ADINCO
IF 0 = (SELECT  COUNT(1)
	   FROM	   ADINCO_DESARROLLO.dbo.PV_Subcontratista ADINCO
	   JOIN	   INSERTED	I
		  ON  ADINCO.RFC	COLLATE Modern_Spanish_CI_AS =   I.RFC 
	   )
BEGIN
-- SE INSERTA EL PROVEEDOR EN ADINCO
	INSERT INTO ADINCO_DESARROLLO.dbo.PV_Subcontratista
	(
	   RFC,
	   RazonSocial,
	   RepresentanteLegal,
	   DiasCreditoID,
	   Giro,
	   PatronalIMSS,
	   TipoPersonaFiscalID,
	   NacionalidadID,
	   ClasificacionID,
	   Capital,
	   IdStatusValidacion,
	   MotivoRechazo,
	   NombreComercial,
	   CURP,
	   FormaPagoID,
	   GrupoCuentasID,
	   UsuarioID,
	   IdPetroVendor
	   --RegimenCapital
	   --FechaConstitucion
	   --FechaOperacion
	   --SituacionContribuyente
	   --FechaCambioSituacion
	   --Pais
	   --Entidad
	   --Municipio
	   --Colonia
	   --TipoVialidad
	   --NombreVialidad
	   --NumExterior
	   --NumInterior
	   --CodigoPostal
	   --IsEliminado
	   --ImagenSrc
	   --Relacionada
	)
	SELECT
	   RFC,
	   RazonSocial,
	   RepresentanteLegal,
	   DiasCreditoID,
	   Giro,
	   PatronalIMSS,
	   TipoPersonaFiscalID,
	   NacionalidadID,
	   ClasificacionID,
	   Capital,
	   IdStatusValidacion,
	   MotivoRechazo,
	   NombreComercial,
	   CURP,
	   FormaPagoID,
	   GrupoCuentasID,
	   UsuarioID,
	   IdSubcontratista
	FROM
		INSERTED
		
END
ELSE
BEGIN
    -- SI YA EXISTE EL PROVEEDOR, SOLO LE ACTUALIZAMOS EL ID PETROVENDOR
    UPDATE  ADINCO
	   SET IdPetroVendor   =	  I.IdSubcontratista,
	   RazonSocial		   =	  I.RazonSocial,
	   RepresentanteLegal  =	  I.RepresentanteLegal,
	   DiasCreditoID	   =	  I.DiasCreditoID,
	   Giro			   =	  I.Giro,
	   PatronalIMSS	   =	  I.PatronalIMSS,
	   TipoPersonaFiscalID =	  I.TipoPersonaFiscalID,
	   NacionalidadID	   =	  I.NacionalidadID,
	   ClasificacionID	   =	  I.ClasificacionID,
	   Capital		   =	  I.Capital,
	   IdStatusValidacion  =	  I.IdStatusValidacion,
	   MotivoRechazo	   =	  I.MotivoRechazo,
	   NombreComercial	   =	  I.NombreComercial,
	   CURP			   =	  I.CURP,
	   FormaPagoID		   =	  I.FormaPagoID,
	   GrupoCuentasID	   =	  I.GrupoCuentasID
    FROM
    	   ADINCO_DESARROLLO.dbo.PV_Subcontratista ADINCO
    JOIN
    	   INSERTED	I
	   ON  ADINCO.RFC COLLATE Modern_Spanish_CI_AS	=   I.RFC	 
END

FIN:

END
