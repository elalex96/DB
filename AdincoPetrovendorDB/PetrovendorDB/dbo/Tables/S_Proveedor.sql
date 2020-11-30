CREATE TABLE [dbo].[S_Proveedor] (
    [IdProveedor]                 INT            IDENTITY (1, 1) NOT NULL,
    [IdNacionalidad]              INT            NOT NULL,
    [RFC]                         VARCHAR (30)   NOT NULL,
    [IdTipoRegimen]               INT            NULL,
    [RazonSocial]                 NVARCHAR (MAX) NOT NULL,
    [RegimenCapital]              NVARCHAR (MAX) NULL,
    [FechaConstitucion]           NVARCHAR (15)  NULL,
    [FechaOperacion]              NVARCHAR (15)  NULL,
    [SituacionContribuyente]      NVARCHAR (15)  NULL,
    [FechaCambioSituacion]        NVARCHAR (15)  NULL,
    [Pais]                        NVARCHAR (50)  CONSTRAINT [DF_S_Proveedor_Pais] DEFAULT (N'México') NULL,
    [Entidad]                     NVARCHAR (50)  NULL,
    [Municipio]                   NVARCHAR (50)  NULL,
    [Colonia]                     NVARCHAR (50)  NULL,
    [TipoVialidad]                NVARCHAR (50)  NULL,
    [NombreVialidad]              NVARCHAR (50)  NULL,
    [NumExterior]                 NVARCHAR (8)   NULL,
    [NumInterior]                 NVARCHAR (8)   NULL,
    [CodigoPostal]                NVARCHAR (10)  NULL,
    [Alias]                       NVARCHAR (200) NULL,
    [IsEliminado]                 BIT            NULL,
    [ImagenSrc]                   NVARCHAR (150) NULL,
    [Activo]                      BIT            NULL,
    [IdPais]                      INT            NULL,
    [DiasCredito]                 INT            NULL,
    [CURP]                        NVARCHAR (20)  NULL,
    [RPPC]                        NVARCHAR (50)  NULL,
    [Giro]                        NVARCHAR (100) NULL,
    [MonedaFacturar]              INT            NULL,
    [IMSS]                        NVARCHAR (50)  NULL,
    [Telefono]                    NVARCHAR (20)  NULL,
    [CapitalContable]             FLOAT (53)     NULL,
    [IdTipoMoneda]                INT            NULL,
    [EditadoEl]                   DATETIME       NULL,
    [EditadoPor]                  INT            NULL,
    [CorreoProveedor]             VARCHAR (50)   NULL,
    [AnteriorInhabilitadoSFP]     BIT            NULL,
    [FechaFinalizacionSancionSFP] NVARCHAR (50)  NULL,
    [InhabilitadoSFP]             BIT            NULL,
    [IdRegimenCapital]            INT            NULL,
    [Verificable]                 BIT            NULL,
    [EdicionCN]                   BIT            NULL,
    [CotizacionesRestringidas]    BIT            NULL,
    CONSTRAINT [PK_S_Proveedor] PRIMARY KEY CLUSTERED ([IdProveedor] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    FOREIGN KEY ([IdTipoMoneda]) REFERENCES [dbo].[PV_TipoMoneda] ([IdMoneda]),
    CONSTRAINT [FK__S_Proveed__IdNac__0E04126B] FOREIGN KEY ([IdNacionalidad]) REFERENCES [dbo].[S_Nacionalidad] ([IdNacionalidad]),
    CONSTRAINT [FK__S_Proveed__IdTip__0D0FEE32] FOREIGN KEY ([IdTipoRegimen]) REFERENCES [dbo].[S_TipoRegimen] ([IdTipoRegimen])
);


GO
-- =============================================
-- Author:		Manuel Cruz
-- Create date: 24-04-17
-- Description:	
-- =============================================
CREATE TRIGGER [dbo].[S_Proveedor_UTRG] ON [dbo].[S_Proveedor]
FOR UPDATE
NOT FOR REPLICATION
AS
     BEGIN
         -- SET NOCOUNT ON added to prevent extra result sets from
         -- interfering with SELECT statements.
         IF @@ROWCOUNT = 0
             GOTO FIN

         SET NOCOUNT ON

         -- Insert statements for trigger here
	    -- VALIDAMOS SI YA EXISTE EL PROVEEDOR EN LA TABLA DE ADINCO YA SEA CON EL RFC O CON EL ID
	   -- IF 0 = (SELECT  COUNT(1)
		 	--  FROM	   ADINCO.dbo.PV_Subcontratista ADINCO
		 	--  JOIN	   INSERTED	I
		 	--  ON  ADINCO.RFC	COLLATE Modern_Spanish_CI_AS =   I.RFC
			 --)
			 --AND
		  --0 = (SELECT  COUNT(1)
			 -- FROM	   ADINCO.dbo.PV_Subcontratista ADINCO
			 -- JOIN	   INSERTED	I
			 -- ON  ADINCO.IdPetroVendor	=   I.IdProveedor
			 --)
    --         BEGIN
    --             -- SE INSERTA EL PROVEEDOR EN ADINCO
    --             INSERT INTO ADINCO.dbo.PV_Subcontratista
    --             (RFC,
    --              RazonSocial,
    --              TipoPersonaFiscalID,
    --              NacionalidadID,
    --              NombreComercial,
    --              RegimenCapital,
    --              FechaConstitucion,
    --              FechaOperacion,
    --              SituacionContribuyente,
    --              FechaCambioSituacion,
    --              Pais,
    --              Entidad,
    --              Municipio,
    --              Colonia,
    --              TipoVialidad,
    --              NombreVialidad,
    --              NumExterior,
    --              NumInterior,
    --              CodigoPostal,
    --              IsEliminado,
    --              ImagenSrc,
    --              IdPetroVendor
    --             )
    --                    SELECT RFC,
    --                           RazonSocial,
    --                           IdTipoRegimen,
    --                           IdNacionalidad,
    --                           Alias,
    --                           RegimenCapital,
    --                           FechaConstitucion,
    --                           FechaOperacion,
    --                           SituacionContribuyente,
    --                           FechaCambioSituacion,
    --                           Pais,
    --                           Entidad,
    --                           Municipio,
    --                           Colonia,
    --                           TipoVialidad,
    --                           NombreVialidad,
    --                           NumExterior,
    --                           NumInterior,
    --                           CodigoPostal,
    --                           IsEliminado,
    --                           ImagenSrc,
    --                           IdProveedor
    --                    FROM INSERTED
				--    WHERE Activo = 1
    --         END
    --     ELSE
    --         BEGIN
    --             -- SI YA EXISTE EL PROVEEDOR, SOLO LE ACTUALIZAMOS EL ID PETROVENDOR
    --             UPDATE ADINCO
    --               SET
    --                   IdPetroVendor = I.IdProveedor,
    --                   RazonSocial = I.RazonSocial,
    --                   TipoPersonaFiscalID = I.IdTipoRegimen,
    --                   NacionalidadID = I.IdNacionalidad,
    --                   NombreComercial = I.Alias,
    --                   RegimenCapital = I.RegimenCapital,
    --                   FechaConstitucion = I.FechaConstitucion,
    --                   FechaOperacion = I.FechaOperacion,
    --                   SituacionContribuyente = I.SituacionContribuyente,
    --                   FechaCambioSituacion = I.FechaCambioSituacion,
    --                   Pais = I.Pais,
    --                   Entidad = I.Entidad,
    --                   Municipio = I.Municipio,
    --                   Colonia = I.Colonia,
    --                   TipoVialidad = I.TipoVialidad,
    --                   NombreVialidad = I.NombreVialidad,
    --                   NumExterior = I.NumExterior,
    --                   NumInterior = I.NumInterior,
    --                   CodigoPostal = I.CodigoPostal,
    --                   IsEliminado = I.IsEliminado,
    --                   ImagenSrc = I.ImagenSrc
    --             FROM ADINCO.dbo.PV_Subcontratista ADINCO
    --                  JOIN INSERTED I ON ADINCO.RFC COLLATE Modern_Spanish_CI_AS = I.RFC
    --         END
         FIN:
     END