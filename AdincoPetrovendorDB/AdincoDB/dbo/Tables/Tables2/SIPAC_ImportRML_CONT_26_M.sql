/****** Object:  Table [dbo].[SIPAC_ImportRML_CONT_26_M]    Script Date: 16/04/2021 01:14:02 p. m. ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[SIPAC_ImportRML_CONT_26_M](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[IdBitacora] [int] NOT NULL,
	[RF_00] [varchar](200) NULL,
	[RI_00] [varchar](200) NULL,
	[RF01_01] [varchar](200) NULL,
	[RMLCT26_00] [tinyint] NULL,
	[RMLCT26_01] [smallint] NULL,
	[RMLCT26_02] [int] NULL,
	[RMLCT26_03] [int] NULL,
	[RMLCT26_04] [int] NULL,
	[RMLCT26_05] [int] NULL,
	[RMLCT26_06] [int] NULL,
	[RMLCT26_07] [int] NULL,
	[RMLCT26_08] [int] NULL,
	[RMLCT26_09] [int] NULL,
	[RMLCT26_10] [int] NULL,
	[RMLCT26_11] [int] NULL,
	[RMLCT26_12] [int] NULL,
	[RMLCT26_13] [int] NULL,
	[RMLCT26_14] [int] NULL,
	[RMLCT26_15] [int] NULL,
	[RMLCT26_16] [int] NULL,
	[RMLCT26_17] [decimal](10, 4) NULL,
	[RMLCT26_18] [decimal](10, 4) NULL,
	[RMLCT26_19] [decimal](10, 4) NULL,
	[RMLCT26_20] [decimal](10, 4) NULL,
	[RMLCT26_21] [decimal](10, 2) NULL,
	[RMLCT26_22] [tinyint] NULL,
	[RMLCT26_23] [tinyint] NULL,
	[RMLCT26_24] [tinyint] NULL,
	[RMLCT26_25] [tinyint] NULL,
	[RMLCT26_26] [tinyint] NULL,
	[RMLCT26_27] [tinyint] NULL,
	[RMLCT26_28] [tinyint] NULL,
	[RMLCT26_29] [tinyint] NULL,
	[RMLCT26_30] [tinyint] NULL,
	[RMLCT26_31] [tinyint] NULL,
	[RMLCT26_32] [float] NULL,
	[RMLCT26_33] [float] NULL,
	[RMLCT26_34] [float] NULL,
	[RMLCT26_35] [float] NULL,
	[RMLCT26_36] [float] NULL,
	[CreadoPor] [int] NULL,
	[CreadoEl] [datetime] NULL,
 CONSTRAINT [PK_SIPAC_ImportRML_CONT_26_M] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[SIPAC_ImportRML_CONT_26_M]  WITH CHECK ADD  CONSTRAINT [FK_SIPAC_ImportRML_CONT_26_M_AP_Usuario] FOREIGN KEY([CreadoPor])
REFERENCES [dbo].[AP_Usuario] ([UsuarioID])
GO

ALTER TABLE [dbo].[SIPAC_ImportRML_CONT_26_M] CHECK CONSTRAINT [FK_SIPAC_ImportRML_CONT_26_M_AP_Usuario]
GO

ALTER TABLE [dbo].[SIPAC_ImportRML_CONT_26_M]  WITH CHECK ADD  CONSTRAINT [FK_SIPAC_ImportRML_CONT_26_M_SIPAC_ImportBitacora] FOREIGN KEY([IdBitacora])
REFERENCES [dbo].[SIPAC_ImportBitacora] ([Id])
GO

ALTER TABLE [dbo].[SIPAC_ImportRML_CONT_26_M] CHECK CONSTRAINT [FK_SIPAC_ImportRML_CONT_26_M_SIPAC_ImportBitacora]
GO


